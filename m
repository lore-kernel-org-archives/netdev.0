From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2015-11-20
Date: Fri, 20 Nov 2015 12:32:42 +0200
Message-ID: <87egflt0z9.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here first wireless-driver fixes for 4.4. Here there are few patches
adding new device support and a new firmware but I think they are
justified at this early stage of release cycle. Otherwise there should
not be anything special, all patches are really small. Please let me
know if you have any problems.

Kalle

The following changes since commit f1a454a37618b819f2528ccd234f77a02b3a6016:

  ipg: Remove ipg driver (2015-11-16 17:11:31 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2015-11-20

for you to fetch changes up to eeec5d0ef7ee54a75e09e861c3cc44177b8752c7:

  rtlwifi: rtl8821ae: Fix lockups on boot (2015-11-17 15:58:53 +0200)

----------------------------------------------------------------
iwlwifi

* bump API to firmware 19 - not released yet.
* fix D3 flows (Luca)
* new device IDs (Oren)
* fix NULL pointer dereference (Avri)

ath10k

* fix invalid NSS for 4x4 devices
* add QCA9377 hw1.0 support
* fix QCA6174 regression with CE5 usage

wil6210

* new maintainer - Maya Erez

rtlwifi

* rtl8821ae: Fix lockups on boot

----------------------------------------------------------------
Avri Altman (1):
      iwlwifi: mvm: Avoid dereferencing sta if it was already flushed

Bartosz Markowski (4):
      ath10k: fix the currently supported QCA9377 target version name
      ath10k: update missing hw_params of QCA9377 hw1.1
      ath10k: introduce dev_id to hw_params
      ath10k: add QCA9377 hw1.0 support

Emmanuel Grumbach (1):
      iwlwifi: bump firmware API to 19

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2015-11-15' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge ath-current from ath.git

Larry Finger (1):
      rtlwifi: rtl8821ae: Fix lockups on boot

Luca Coelho (1):
      iwlwifi: mvm: don't overwrite the key indices in D3 entry

Oren Givon (1):
      iwlwifi: Add new PCI IDs for the 8260 series

Rajkumar Manoharan (2):
      ath10k: fix invalid NSS for 4x4 devices
      ath10k: poll HTT send completion when CE 5 is unused

Ryan Hsu (1):
      ath10k: override CE5 configuration for QCA6147 device

Vladimir Kondratiev (1):
      MAINTAINERS: wil6210: new maintainer - Maya Erez

 MAINTAINERS                                        |    2 +-
 drivers/net/wireless/ath/ath10k/core.c             |   49 ++++++++++-
 drivers/net/wireless/ath/ath10k/core.h             |    1 +
 drivers/net/wireless/ath/ath10k/hw.h               |   17 +++-
 drivers/net/wireless/ath/ath10k/mac.c              |    2 +-
 drivers/net/wireless/ath/ath10k/pci.c              |   53 +++++++++---
 drivers/net/wireless/iwlwifi/iwl-7000.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |    2 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |    8 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   11 ++-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   88 +++++++++++---------
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    4 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   19 ++++-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |    2 +-
 15 files changed, 189 insertions(+), 73 deletions(-)
