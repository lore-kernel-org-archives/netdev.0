From: Jan Dumon <j.dumon@option.com>
Subject: [PATCH] hso: add Vendor/Product ID's for new devices
Date: Tue, 31 Mar 2009 13:56:52 +0200
Message-ID: <20090331115652.GA22106@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:23991 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466AbZCaL45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 07:56:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>

Add Vendor/Product ID's for new devices.

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
