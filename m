From: Peter Korsgaard <peter@korsgaard.com>
Subject: [PATCH] dm9601: add USB IDs for new dm96xx variants
Date: Sun, 12 Jan 2014 23:15:51 +0100
Message-ID: <1389564951-7049-1-git-send-email-peter@korsgaard.com>
Cc: joseph_chang@davicom.com.tw, Peter Korsgaard <peter@korsgaard.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:38988 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbaALWQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 17:16:05 -0500
Received: by mail-wg0-f42.google.com with SMTP id l18so2174632wgh.1
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 14:16:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of new dm96xx variants now exist.

Reported-by: Joseph Chang <joseph_chang@davicom.com.tw>
Signed-off-by: Peter Korsgaard <peter@korsgaard.com>
---
 drivers/net/usb/dm9601.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 14aa48f..e802198 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -614,6 +614,18 @@ static const struct usb_device_id products[] = {
 	 USB_DEVICE(0x0a46, 0x9621),	/* DM9621A USB to Fast Ethernet Adapter */
 	 .driver_info = (unsigned long)&dm9601_info,
 	},
+	{
+	 USB_DEVICE(0x0a46, 0x9622),	/* DM9622 USB to Fast Ethernet Adapter */
+	 .driver_info = (unsigned long)&dm9601_info,
+	},
+	{
+	 USB_DEVICE(0x0a46, 0x0269),	/* DM962OA USB to Fast Ethernet Adapter */
+	 .driver_info = (unsigned long)&dm9601_info,
+	},
+	{
+	 USB_DEVICE(0x0a46, 0x1269),	/* DM9621A USB to Fast Ethernet Adapter */
+	 .driver_info = (unsigned long)&dm9601_info,
+	},
 	{},			// END
 };
 
-- 
1.8.5.2
