From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 0/7] rtlwifi: Patches to fix problems shown by smatch
Date: Fri, 13 Sep 2013 12:44:57 -0500
Message-ID: <1379094304-22041-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

*** BLURB HERE ***

Larry Finger (7):
  rtlwifi: rtl8192du: Fix smatch errors in /rtl8192de/dm.c
  rtlwifi: rtl8192de: Fix smatch warnings in rtl8192de/hw.c
  rtlwifi: rtl8192cu: Fix smatch warning in rtl8192cu/trx.c
  rtlwifi: rtl8192_common: Fix smatch errors and warnings in
    rtl8192c/dm_common.c
  rtlwifi: Fix smatch warning in pci.c
  rtlwifi: Fix smatch warnings in usb.c
  rtlwifi: rtl8188ee: Fix smatch warning in rtl8188ee/hw.c

 drivers/net/wireless/rtlwifi/pci.c                |   2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c       |   1 +
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c      | 187 +---------------------
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c      |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c       |   8 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c       |   2 +
 drivers/net/wireless/rtlwifi/usb.c                |  10 +-
 8 files changed, 23 insertions(+), 193 deletions(-)

-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
