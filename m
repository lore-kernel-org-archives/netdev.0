From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 0/8 V4] rtlwifi: Patches to fix problems shown by smatch
Date: Wed, 25 Sep 2013 12:57:41 -0500
Message-ID: <1380131869-19185-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix smatch warnings and errors in the rtlwifi family of drivers.

V2 addresses comments by David Laight and Sergei Shtylyov.
V3 addresses further comments by David, Sergei, and Kalle Valo. The
   dead code is removed, and the variable is left in the struct.
V4 Fixes extra line removed by accident from rtl8192de/hw.c as
   noted by Sergei

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

Larry Finger (8):
  rtlwifi: rtl8192du: Fix smatch errors in /rtl8192de/dm.c
  rtlwifi: rtl8192de: Fix smatch warnings in rtl8192de/hw.c
  rtlwifi: rtl8192cu: Fix smatch warning in rtl8192cu/trx.c
  rtlwifi: rtl8192_common: Fix smatch errors and warnings in
    rtl8192c/dm_common.c
  rtlwifi: Fix smatch warning in pci.c
  rtlwifi: Fix smatch warnings in usb.c
  rtlwifi: rtl8188ee: Fix smatch warning in rtl8188ee/hw.c
  rtlwifi: Remove all remaining references to variable 'noise' in
    rtl_stats struct

 drivers/net/wireless/rtlwifi/pci.c                |  1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c       |  1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c      |  1 -
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c | 25 +----------------------
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c      |  1 -
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c      |  2 --
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c       |  8 ++++++--
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c       | 18 ----------------
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c      |  1 -
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c      |  1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c      |  1 -
 drivers/net/wireless/rtlwifi/usb.c                |  6 ++++--
 12 files changed, 12 insertions(+), 54 deletions(-)

-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
