From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 0/3] ath: printk cleanups and code reduction
Date: Sun, 18 Mar 2012 17:30:51 -0700
Message-ID: <cover.1332116921.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	ath9k-devel@lists.ath9k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (3):
  ath: Add and use pr_fmt, convert printks to pr_<level>
  ath5k: Introduce _ath5k_printk to reduce code/text
  ath6kl: Add __printf verification to ath6kl_printk

 drivers/net/wireless/ath/ath5k/ani.c          |   44 +++++++++++--------------
 drivers/net/wireless/ath/ath5k/ath5k.h        |   29 +++++++++-------
 drivers/net/wireless/ath/ath5k/attach.c       |    2 +
 drivers/net/wireless/ath/ath5k/base.c         |   22 ++++++++++++
 drivers/net/wireless/ath/ath5k/debug.c        |   17 ++++++----
 drivers/net/wireless/ath/ath5k/desc.c         |    2 +
 drivers/net/wireless/ath/ath5k/dma.c          |    2 +
 drivers/net/wireless/ath/ath5k/eeprom.c       |    2 +
 drivers/net/wireless/ath/ath5k/initvals.c     |    5 ++-
 drivers/net/wireless/ath/ath5k/led.c          |    2 +
 drivers/net/wireless/ath/ath5k/mac80211-ops.c |    2 +
 drivers/net/wireless/ath/ath5k/pci.c          |    4 ++-
 drivers/net/wireless/ath/ath5k/phy.c          |    2 +
 drivers/net/wireless/ath/ath5k/qcu.c          |    2 +
 drivers/net/wireless/ath/ath5k/reset.c        |    2 +
 drivers/net/wireless/ath/ath5k/sysfs.c        |    2 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c    |    2 +
 drivers/net/wireless/ath/ath6kl/common.h      |    3 +-
 drivers/net/wireless/ath/ath6kl/init.c        |    2 +
 drivers/net/wireless/ath/ath6kl/main.c        |    2 +
 drivers/net/wireless/ath/ath6kl/txrx.c        |    2 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |    8 ++--
 drivers/net/wireless/ath/ath9k/htc_hst.c      |    7 ++--
 drivers/net/wireless/ath/ath9k/init.c         |   13 +++----
 drivers/net/wireless/ath/ath9k/pci.c          |    9 +++--
 drivers/net/wireless/ath/main.c               |    4 ++-
 drivers/net/wireless/ath/regd.c               |    4 ++-
 27 files changed, 128 insertions(+), 69 deletions(-)

-- 
1.7.8.111.gad25c.dirty
