From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 0/8] brcm80211: Logging cleanups
Date: Sun, 15 Jan 2012 00:38:37 -0800
Message-ID: <cover.1326616556.git.joe@perches.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches (8):
  brcm80211: Use normal DEBUG define
  brcmfmac: Convert printk(KERN_DEBUG to pr_debug
  brcm80211: Add and use brcmX_dbg_dump_hex
  brcmfmac: Remove useless #ifdef DEBUG
  brcm80211: Convert printk(KERN_DEBUG to pr_debug
  brcm80211: Use brcmu_dbg_hex_dump
  brcm80211: Use pr_fmt and pr_<level>
  brcmfmac: Trivial typo of "couldn" to "could" fix

 drivers/net/wireless/brcm80211/Makefile            |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |    2 +
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    3 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |    2 +
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   17 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   20 ++-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  216 ++++++++------------
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |    2 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    6 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   36 ++--
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |    4 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |    8 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   24 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.h  |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  194 ++++++++----------
 drivers/net/wireless/brcm80211/brcmsmac/main.h     |    6 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |    5 +-
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |   26 ++-
 .../net/wireless/brcm80211/include/brcmu_utils.h   |   15 ++-
 22 files changed, 298 insertions(+), 304 deletions(-)

-- 
1.7.8.111.gad25c.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
