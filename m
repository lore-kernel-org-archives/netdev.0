From: Fabio Porcedda <fabio.porcedda@gmail.com>
Subject: [PATCH 3/3] net: usb: cdc_ether: use usb.h macros whenever possible
Date: Mon, 16 Sep 2013 11:47:52 +0200
Message-ID: <1379324872-15944-4-git-send-email-fabio.porcedda@gmail.com>
References: <1379324872-15944-1-git-send-email-fabio.porcedda@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:46757 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309Ab3IPJsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 05:48:06 -0400
In-Reply-To: <1379324872-15944-1-git-send-email-fabio.porcedda@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use USB_DEVICE_AND_INTERFACE_INFO and USB_VENDOR_AND_INTERFACE_INFO
macros to reduce boilerplate.

Signed-off-by: Fabio Porcedda <fabio.porcedda@gmail.com>
---
 drivers/net/usb/cdc_ether.c | 63 ++++++++++++---------------------------------
 1 file changed, 17 insertions(+), 46 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index c36b1c3..2023f3e 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -665,58 +665,33 @@ static const struct usb_device_id	products[] = {
  */
 {
 	/* ZTE (Vodafone) K3805-Z */
-	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
-		 | USB_DEVICE_ID_MATCH_PRODUCT
-		 | USB_DEVICE_ID_MATCH_INT_INFO,
-	.idVendor               = ZTE_VENDOR_ID,
-	.idProduct		= 0x1003,
-	.bInterfaceClass	= USB_CLASS_COMM,
-	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
-	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	USB_DEVICE_AND_INTERFACE_INFO(ZTE_VENDOR_ID, 0x1003, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long)&wwan_info,
 }, {
 	/* ZTE (Vodafone) K3806-Z */
-	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
-		 | USB_DEVICE_ID_MATCH_PRODUCT
-		 | USB_DEVICE_ID_MATCH_INT_INFO,
-	.idVendor               = ZTE_VENDOR_ID,
-	.idProduct		= 0x1015,
-	.bInterfaceClass	= USB_CLASS_COMM,
-	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
-	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	USB_DEVICE_AND_INTERFACE_INFO(ZTE_VENDOR_ID, 0x1015, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long)&wwan_info,
 }, {
 	/* ZTE (Vodafone) K4510-Z */
-	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
-		 | USB_DEVICE_ID_MATCH_PRODUCT
-		 | USB_DEVICE_ID_MATCH_INT_INFO,
-	.idVendor               = ZTE_VENDOR_ID,
-	.idProduct		= 0x1173,
-	.bInterfaceClass	= USB_CLASS_COMM,
-	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
-	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	USB_DEVICE_AND_INTERFACE_INFO(ZTE_VENDOR_ID, 0x1173, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long)&wwan_info,
 }, {
 	/* ZTE (Vodafone) K3770-Z */
-	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
-		 | USB_DEVICE_ID_MATCH_PRODUCT
-		 | USB_DEVICE_ID_MATCH_INT_INFO,
-	.idVendor               = ZTE_VENDOR_ID,
-	.idProduct		= 0x1177,
-	.bInterfaceClass	= USB_CLASS_COMM,
-	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
-	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	USB_DEVICE_AND_INTERFACE_INFO(ZTE_VENDOR_ID, 0x1177, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long)&wwan_info,
 }, {
 	/* ZTE (Vodafone) K3772-Z */
-	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
-		 | USB_DEVICE_ID_MATCH_PRODUCT
-		 | USB_DEVICE_ID_MATCH_INT_INFO,
-	.idVendor               = ZTE_VENDOR_ID,
-	.idProduct		= 0x1181,
-	.bInterfaceClass	= USB_CLASS_COMM,
-	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
-	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	USB_DEVICE_AND_INTERFACE_INFO(ZTE_VENDOR_ID, 0x1181, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long)&wwan_info,
 }, {
 	/* Telit modules */
@@ -734,12 +709,8 @@ static const struct usb_device_id	products[] = {
 
 }, {
 	/* Various Huawei modems with a network port like the UMG1831 */
-	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
-		 | USB_DEVICE_ID_MATCH_INT_INFO,
-	.idVendor               = HUAWEI_VENDOR_ID,
-	.bInterfaceClass	= USB_CLASS_COMM,
-	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
-	.bInterfaceProtocol	= 255,
+	USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET, 255),
 	.driver_info = (unsigned long)&wwan_info,
 },
 	{ },		/* END */
-- 
1.8.4
