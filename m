From: Jan Dumon <j.dumon@option.com>
Subject: [PATCH] hso: add Vendor/Product ID's for new devices
Date: Wed, 1 Apr 2009 10:57:51 +0200
Message-ID: <20090401085751.GA7869@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	David Miller <davem@davemloft.net>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:5934 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbZDAI55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 04:57:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>

Add Vendor/Product ID's for new devices.
Removed duplicate product ID 0x7361.

Signed-off-by: Jan Dumon <j.dumon@option.com>
---
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index fe98aca..d47c508 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -462,9 +462,16 @@ static const struct usb_device_id hso_ids[] = {
 	{USB_DEVICE(0x0af0, 0x7701)},
 	{USB_DEVICE(0x0af0, 0x7801)},
 	{USB_DEVICE(0x0af0, 0x7901)},
-	{USB_DEVICE(0x0af0, 0x7361)},
-	{USB_DEVICE(0x0af0, 0xd057)},
+	{USB_DEVICE(0x0af0, 0x8200)},
+	{USB_DEVICE(0x0af0, 0x8201)},
+	{USB_DEVICE(0x0af0, 0xd035)},
 	{USB_DEVICE(0x0af0, 0xd055)},
+	{USB_DEVICE(0x0af0, 0xd155)},
+	{USB_DEVICE(0x0af0, 0xd255)},
+	{USB_DEVICE(0x0af0, 0xd057)},
+	{USB_DEVICE(0x0af0, 0xd157)},
+	{USB_DEVICE(0x0af0, 0xd257)},
+	{USB_DEVICE(0x0af0, 0xd357)},
 	{}
 };
 MODULE_DEVICE_TABLE(usb, hso_ids);
