From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH] ipheth: Add iPhone 4S
Date: Wed, 15 Feb 2012 10:50:15 -0700
Message-ID: <1329328215-102360-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	Till Kamppeter <till.kamppeter@gmail.com>
To: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:3589 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753780Ab2BORus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 12:50:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BugLink: http://bugs.launchpad.net/bugs/900802

Cc: stable@vger.kernel.org 3.2+
Signed-off-by: Till Kamppeter <till.kamppeter@gmail.com>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/net/usb/ipheth.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index 13c1f04..ad96164 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -60,6 +60,7 @@
 #define USB_PRODUCT_IPHONE_3GS  0x1294
 #define USB_PRODUCT_IPHONE_4	0x1297
 #define USB_PRODUCT_IPHONE_4_VZW 0x129c
+#define USB_PRODUCT_IPHONE_4S	0x12a0
 
 #define IPHETH_USBINTF_CLASS    255
 #define IPHETH_USBINTF_SUBCLASS 253
@@ -103,6 +104,10 @@ static struct usb_device_id ipheth_table[] = {
 		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_4_VZW,
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
 		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_4S,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
 	{ }
 };
 MODULE_DEVICE_TABLE(usb, ipheth_table);
-- 
1.7.9
