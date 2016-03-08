From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 0/5] wireless: ti: Convert specialized logging macros to kernel style
Date: Mon,  7 Mar 2016 16:19:32 -0800
Message-ID: <cover.1457395071.git.joe@perches.com>
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Using the normal kernel logging mechanisms makes this code
a bit more like other wireless drivers.

Joe Perches (5):
  ti: Convert wl1271_<level> logging macros to dev_<level> or pr_<level>
  ti: wl1251: Convert wl1251_error to wiphy_err/pr_err
  ti: wl1251: Convert wl1251_warning to wiphy_warn
  ti: wl1251: Convert wl1251_notice to wiphy_info/pr_info
  ti: wl1251: Convert wl1251_info to wl1251_debug

 drivers/net/wireless/ti/wl1251/acx.c      |  97 +++++++-----
 drivers/net/wireless/ti/wl1251/boot.c     |  18 +--
 drivers/net/wireless/ti/wl1251/cmd.c      |  52 ++++---
 drivers/net/wireless/ti/wl1251/event.c    |   2 +-
 drivers/net/wireless/ti/wl1251/init.c     |  27 ++--
 drivers/net/wireless/ti/wl1251/io.c       |   3 +-
 drivers/net/wireless/ti/wl1251/main.c     |  75 +++++----
 drivers/net/wireless/ti/wl1251/ps.c       |   2 +-
 drivers/net/wireless/ti/wl1251/rx.c       |   6 +-
 drivers/net/wireless/ti/wl1251/sdio.c     |  25 +--
 drivers/net/wireless/ti/wl1251/spi.c      |  19 +--
 drivers/net/wireless/ti/wl1251/tx.c       |   9 +-
 drivers/net/wireless/ti/wl1251/wl1251.h   |  15 +-
 drivers/net/wireless/ti/wl12xx/acx.c      |   2 +-
 drivers/net/wireless/ti/wl12xx/cmd.c      |  20 +--
 drivers/net/wireless/ti/wl12xx/main.c     |  34 ++--
 drivers/net/wireless/ti/wl12xx/scan.c     |  24 +--
 drivers/net/wireless/ti/wl18xx/acx.c      |  25 +--
 drivers/net/wireless/ti/wl18xx/cmd.c      |  20 +--
 drivers/net/wireless/ti/wl18xx/debugfs.c  |   2 +-
 drivers/net/wireless/ti/wl18xx/event.c    |   8 +-
 drivers/net/wireless/ti/wl18xx/main.c     |  50 +++---
 drivers/net/wireless/ti/wl18xx/scan.c     |  16 +-
 drivers/net/wireless/ti/wl18xx/tx.c       |   8 +-
 drivers/net/wireless/ti/wlcore/acx.c      | 132 ++++++++--------
 drivers/net/wireless/ti/wlcore/boot.c     |  45 +++---
 drivers/net/wireless/ti/wlcore/cmd.c      | 103 +++++++------
 drivers/net/wireless/ti/wlcore/debug.h    |  14 +-
 drivers/net/wireless/ti/wlcore/debugfs.c  |  54 +++----
 drivers/net/wireless/ti/wlcore/event.c    |  14 +-
 drivers/net/wireless/ti/wlcore/main.c     | 248 ++++++++++++++++--------------
 drivers/net/wireless/ti/wlcore/ps.c       |  15 +-
 drivers/net/wireless/ti/wlcore/rx.c       |  26 ++--
 drivers/net/wireless/ti/wlcore/scan.c     |   4 +-
 drivers/net/wireless/ti/wlcore/sysfs.c    |   8 +-
 drivers/net/wireless/ti/wlcore/testmode.c |  14 +-
 drivers/net/wireless/ti/wlcore/tx.c       |  14 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h |   3 -
 38 files changed, 653 insertions(+), 600 deletions(-)

-- 
2.6.3.368.gf34be46

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
