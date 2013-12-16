From: Peter Korsgaard <peter@korsgaard.com>
Subject: [PATCH 1/4] dm9601: add support for dm9621a based dongle
Date: Mon, 16 Dec 2013 11:35:32 +0100
Message-ID: <1387190135-17052-2-git-send-email-peter@korsgaard.com>
References: <1387190135-17052-1-git-send-email-peter@korsgaard.com>
Cc: joseph_chang@davicom.com.tw, Peter Korsgaard <peter@korsgaard.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:45849 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab3LPKfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 05:35:48 -0500
Received: by mail-ea0-f173.google.com with SMTP id o10so2135889eaj.4
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 02:35:47 -0800 (PST)
In-Reply-To: <1387190135-17052-1-git-send-email-peter@korsgaard.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dm9621a is functionally identical to dm9620, so the existing handling can
directly be used.

Thanks to Davicom for sending me a dongle.

Signed-off-by: Peter Korsgaard <peter@korsgaard.com>
---
 drivers/net/usb/dm9601.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index c6867f9..8e88572 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -594,6 +594,10 @@ static const struct usb_device_id products[] = {
 	 USB_DEVICE(0x0a46, 0x9620),	/* DM9620 USB to Fast Ethernet Adapter */
 	 .driver_info = (unsigned long)&dm9601_info,
 	 },
+	{
+	 USB_DEVICE(0x0a46, 0x9621),	/* DM9621A USB to Fast Ethernet Adapter */
+	 .driver_info = (unsigned long)&dm9601_info,
+	},
 	{},			// END
 };
 
-- 
1.8.5.1
