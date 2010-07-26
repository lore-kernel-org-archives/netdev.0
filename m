From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/4] wireless: Add and use wiphy_<level> logging macros
Date: Mon, 26 Jul 2010 14:39:56 -0700
Message-ID: <cover.1280177971.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add some consistent use styles to wiphy messages

Joe Perches (4):
  include/net/cfg80211.h: Add wiphy_<level> printk equivalents
  drivers/net/wireless: Use wiphy_<level>
  drivers/net/wireless/at76c50x-usb.c: Neaten macros
  wireless: Convert wiphy_debug macro to function

 drivers/net/wireless/adm8211.c                 |   53 ++++----
 drivers/net/wireless/at76c50x-usb.c            |  168 +++++++++++------------
 drivers/net/wireless/ath/ar9170/cmd.c          |    7 +-
 drivers/net/wireless/ath/ar9170/led.c          |    4 +-
 drivers/net/wireless/ath/ar9170/main.c         |  172 +++++++++++-------------
 drivers/net/wireless/ath/ar9170/phy.c          |    8 +-
 drivers/net/wireless/ath/ath9k/ahb.c           |    7 +-
 drivers/net/wireless/ath/ath9k/pci.c           |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c         |   11 +-
 drivers/net/wireless/iwlwifi/iwl-core.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c    |   13 +-
 drivers/net/wireless/mac80211_hwsim.c          |   99 +++++++-------
 drivers/net/wireless/mwl8k.c                   |  123 +++++++----------
 drivers/net/wireless/orinoco/cfg.c             |    5 +-
 drivers/net/wireless/p54/eeprom.c              |   76 +++++------
 drivers/net/wireless/p54/fwio.c                |   53 ++++----
 drivers/net/wireless/p54/led.c                 |    8 +-
 drivers/net/wireless/p54/p54pci.c              |    3 +-
 drivers/net/wireless/p54/txrx.c                |   36 +++---
 drivers/net/wireless/rtl818x/rtl8180_dev.c     |   17 +--
 drivers/net/wireless/rtl818x/rtl8187_dev.c     |   11 +-
 drivers/net/wireless/rtl818x/rtl8187_rtl8225.c |    8 +-
 include/net/cfg80211.h                         |   65 +++++++++-
 net/wireless/core.c                            |   53 +++++++
 24 files changed, 528 insertions(+), 481 deletions(-)
