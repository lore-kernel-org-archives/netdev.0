From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [PATCH net-next] ipheth: Add support for iPad 2 and iPad 3
Date: Fri, 30 May 2014 12:17:00 +0200
Message-ID: <1401445020-14027-1-git-send-email-kristian.evensen@gmail.com>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38652 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755221AbaE3KRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 06:17:09 -0400
Received: by mail-wi0-f181.google.com with SMTP id n15so841410wiw.8
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 03:17:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>

Each iPad model has a different product id, this patch adds support for iPad 2
(pid 0x12a2) and iPad 3 (pid 0x12a6). Note that iPad 2 must be jailbroken and a
third-party app must be used for tethering to work. On iPad 3, tethering works
out of the box (assuming your ISP is nice).

Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
---
 drivers/net/usb/ipheth.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index 421934c..973275f 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -59,6 +59,8 @@
 #define USB_PRODUCT_IPHONE_3GS  0x1294
 #define USB_PRODUCT_IPHONE_4	0x1297
 #define USB_PRODUCT_IPAD 0x129a
+#define USB_PRODUCT_IPAD_2	0x12a2
+#define USB_PRODUCT_IPAD_3	0x12a6
 #define USB_PRODUCT_IPAD_MINI    0x12ab
 #define USB_PRODUCT_IPHONE_4_VZW 0x129c
 #define USB_PRODUCT_IPHONE_4S	0x12a0
@@ -107,6 +109,14 @@ static struct usb_device_id ipheth_table[] = {
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
 		IPHETH_USBINTF_PROTO) },
 	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPAD_2,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPAD_3,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
 		USB_VENDOR_APPLE, USB_PRODUCT_IPAD_MINI,
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
 		IPHETH_USBINTF_PROTO) },
-- 
1.8.3.2
