#!/usr/bin/env bash
set -euo pipefail

# The base image ships Python 3.12 and pip but not the venv module or unzip,
# both of which this project needs. Install them idempotently.
missing_pkgs=()
dpkg -s python3.12-venv >/dev/null 2>&1 || missing_pkgs+=(python3.12-venv)
command -v unzip >/dev/null 2>&1 || missing_pkgs+=(unzip)
if [ "${#missing_pkgs[@]}" -gt 0 ]; then
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends "${missing_pkgs[@]}"
fi

# The application source is distributed as a zip in the repo root. Extract it
# (overwriting any previous extraction) so the code is available on disk.
unzip -o domain_pro_tool.zip

# Create or reuse an isolated virtualenv and install pinned dependencies.
python3 -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
pip install -r domain_pro_tool/requirements.txt
