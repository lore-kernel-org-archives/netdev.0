From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2016-01-29
Date: Fri, 29 Jan 2016 10:47:19 +0200
Message-ID: <8737tgkc14.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

few fixes for 4.5. Nothing really standing out, see the tag for
more info. Please let me know if you have any problems.

Kalle

The following changes since commit a200dcb34693084e56496960d855afdeaaf9578f:

  Merge tag 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost (2016-01-18 16:44:24 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-01-29

for you to fetch changes up to f9ead9beef3f44be0db4b542a8c2ce698fb1530e:

  Merge tag 'iwlwifi-for-kalle-2016-01-26_2' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-01-27 14:19:18 +0200)

----------------------------------------------------------------

iwlwifi

* Fix support for 3168 device:
  * NVM version
  * firmware file name
  * device IDs
* Fix a compilation warning in dvm calibration code
* Fix the TPC (reduced Tx Power) code. This fixes performance issues
* Add device IDs for 8265

rtx2x00

* fix monitor mode regression dating back to 4.1

brcmfmac

* fix sdio initialisation related crash

rtlwifi

* rtl8821ae: Fix 5G failure when EEPROM is incorrectly encoded

ath9k

* ignore eeprom magic mismatch on flash based devices

----------------------------------------------------------------
Arnd Bergmann (1):
      ssb: mark ssb_bus_register as __maybe_unused

Eli Cooper (1):
      rt2x00: fix monitor mode regression

Felix Fietkau (2):
      brcmfmac: add missing include
      ath9k_hw: ignore eeprom magic mismatch on flash based devices

Gregory Greenman (1):
      iwlwifi: mvm: rs: fix TPC statistics handling

Hante Meuleman (1):
      brcmfmac: fix sdio sg table alloc crash

Kalle Valo (2):
      Merge ath-current from ath.git
      Merge tag 'iwlwifi-for-kalle-2016-01-26_2' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: rtl8821ae: Fix 5G failure when EEPROM is incorrectly encoded

Michael Buesch (1):
      ssb: Set linux-wireless as MAINTAINERS list

Oren Givon (3):
      iwlwifi: add new 3168 series devices support
      iwlwifi: add device ID for 8265
      iwlwifi: update support for 3168 series firmware and NVM

 MAINTAINERS                                        |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |   12 ++--
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |   40 ++++-------
 .../wireless/broadcom/brcm80211/brcmfmac/common.c  |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |    5 ++
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.h    |    1 +
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |   23 ++++--
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |   74 +++++++++++++-------
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |    5 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |    4 ++
 drivers/net/wireless/ralink/rt2x00/rt2400pci.c     |    4 +-
 drivers/net/wireless/ralink/rt2x00/rt2500pci.c     |    4 +-
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c     |    4 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |    3 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |    1 +
 drivers/net/wireless/ralink/rt2x00/rt2x00config.c  |    5 ++
 drivers/net/wireless/ralink/rt2x00/rt2x00mac.c     |    5 --
 drivers/net/wireless/ralink/rt2x00/rt61pci.c       |    4 +-
 drivers/net/wireless/ralink/rt2x00/rt73usb.c       |    4 +-
 drivers/net/wireless/realtek/rtlwifi/regd.c        |    2 +-
 drivers/ssb/main.c                                 |    7 +-
 22 files changed, 136 insertions(+), 80 deletions(-)

-- 
Kalle Valo
