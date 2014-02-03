From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2] staging: r8188eu: Fix typo in USB_DEVICE list
Date: Sun,  2 Feb 2014 22:23:06 -0600
Message-ID: <1391401386-28724-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:50566 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbaBCEXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 23:23:13 -0500
Received: by mail-oa0-f42.google.com with SMTP id i7so7721661oag.29
        for <netdev@vger.kernel.org>; Sun, 02 Feb 2014 20:23:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a typo in the device list that interchanges the vendor and
product codes for one of the entries. This exchange was determined
by noticing that the vendor code is 0x07b8 for Abocom at
http://www.linux-usb.org/usb.ids.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

V2 - fix typo in revised version that was spotted by Randy Dunlap.
---

 drivers/staging/rtl8188eu/os_dep/usb_intf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index 0a341d6..a70dcef 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -53,7 +53,7 @@ static struct usb_device_id rtw_usb_id_tbl[] = {
 	{USB_DEVICE(USB_VENDER_ID_REALTEK, 0x0179)}, /* 8188ETV */
 	/*=== Customer ID ===*/
 	/****** 8188EUS ********/
-	{USB_DEVICE(0x8179, 0x07B8)}, /* Abocom - Abocom */
+	{USB_DEVICE(0x07b8, 0x8179)}, /* Abocom - Abocom */
 	{USB_DEVICE(0x2001, 0x330F)}, /* DLink DWA-125 REV D1 */
 	{}	/* Terminating entry */
 };
-- 
1.8.4
