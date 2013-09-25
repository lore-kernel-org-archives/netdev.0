From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/11 - GIT PULL] drivers: net: Last block of Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:18 -0700
Message-ID: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, wimax@linuxwimax.org,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, brcm80211-dev-list@broadcom.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 294da3abaa73a0b69fd54e442b0b5bd9455b7be6:

  irda: Remove extern from function prototypes (2013-09-24 12:54:17 -0700)

are available in the git repository at:

  git://repo.or.cz/linux-2.6/trivial-mods.git 20130925_dn_externs_3

for you to fetch changes up to a958df5dc3065ce517726dc54087639e13ffee8f:

  rtlwifi: Remove extern from function prototypes (2013-09-24 18:06:51 -0700)

----------------------------------------------------------------
Joe Perches (11):
  vmxnet3: Remove extern from function prototypes
  wan: Remove extern from function prototypes
  wimax: Remove extern from function prototypes
  ath: Remove extern from function prototypes
  brcm80211: Remove extern from function prototypes
  ipw2x00: Remove extern from function prototypes
  iwlegacy: Remove extern from function prototypes
  iwlwifi: Remove extern from function prototypes
  mwifiex: Remove extern from function prototypes
  orinoco: Remove extern from function prototypes
  rtlwifi: Remove extern from function prototypes

 drivers/net/vmxnet3/vmxnet3_int.h                  |   4 +-
 drivers/net/wan/x25_asy.h                          |   2 +-
 drivers/net/wan/z85230.h                           |  27 +-
 drivers/net/wimax/i2400m/i2400m-usb.h              |  27 +-
 drivers/net/wimax/i2400m/i2400m.h                  | 117 ++++---
 drivers/net/wireless/ath/ath10k/debug.h            |   8 +-
 drivers/net/wireless/ath/ath6kl/common.h           |   3 +-
 drivers/net/wireless/ath/ath6kl/debug.h            |   9 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |  30 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |  27 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_proto.h    |  12 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.h    |  23 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |  92 +++--
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.h  |  18 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.h    |  22 +-
 drivers/net/wireless/brcm80211/brcmsmac/antsel.h   |  14 +-
 drivers/net/wireless/brcm80211/brcmsmac/channel.h  |  20 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.h  |  38 +--
 drivers/net/wireless/brcm80211/brcmsmac/main.h     | 110 +++---
 .../net/wireless/brcm80211/brcmsmac/phy/phy_hal.h  | 219 ++++++------
 .../net/wireless/brcm80211/brcmsmac/phy/phy_int.h  | 371 ++++++++++-----------
 drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h |  91 +++--
 drivers/net/wireless/brcm80211/brcmsmac/pmu.h      |   4 +-
 drivers/net/wireless/brcm80211/brcmsmac/pub.h      | 145 ++++----
 drivers/net/wireless/brcm80211/brcmsmac/rate.h     |  48 ++-
 drivers/net/wireless/brcm80211/brcmsmac/stf.h      |  31 +-
 .../net/wireless/brcm80211/brcmsmac/ucode_loader.h |  16 +-
 drivers/net/wireless/brcm80211/include/brcmu_d11.h |   2 +-
 .../net/wireless/brcm80211/include/brcmu_utils.h   |  44 ++-
 drivers/net/wireless/ipw2x00/libipw.h              |  87 +++--
 drivers/net/wireless/iwlegacy/3945.h               |  82 +++--
 drivers/net/wireless/iwlegacy/4965.h               |   2 +-
 drivers/net/wireless/iwlegacy/common.h             |  66 ++--
 drivers/net/wireless/iwlwifi/dvm/agn.h             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/rs.h              |   8 +-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |   9 +-
 drivers/net/wireless/mwifiex/wmm.h                 |  24 +-
 drivers/net/wireless/orinoco/orinoco.h             |  31 +-
 drivers/net/wireless/rtlwifi/cam.h                 |  10 +-
 drivers/net/wireless/rtlwifi/efuse.h               |  29 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h       |  49 ++-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.h       |  54 ++-
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.h        |  13 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.h        |  13 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.h        |   7 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.h       |  44 ++-
 drivers/net/wireless/rtlwifi/rtl8192de/rf.h        |  18 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |  61 ++--
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h        |  13 +-
 51 files changed, 1026 insertions(+), 1174 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
