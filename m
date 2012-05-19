From: Andrew Bird <ajb@spheresystems.co.uk>
Subject: [PATCH] USB CDC-Ether - Add ZTE WWAN matches before generic Ethernet
Date: Sat, 19 May 2012 14:56:07 +0100
Message-ID: <1337435767-9544-1-git-send-email-ajb@spheresystems.co.uk>
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Bird <ajb@spheresystems.co.uk>
To: oliver@neukum.name
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some ZTE WWAN devices have generic CDC Ether descriptors. Add those
into the whitelist so that we get FLAG_WWAN on the interface

Signed-off-by: Andrew Bird <ajb@spheresystems.co.uk>
---
 drivers/net/usb/cdc_ether.c |   56 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 425e201..fffee6a 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -486,6 +486,7 @@ static const struct driver_info wwan_info = {
 
 #define HUAWEI_VENDOR_ID	0x12D1
 #define NOVATEL_VENDOR_ID	0x1410
+#define ZTE_VENDOR_ID		0x19D2
 
 static const struct usb_device_id	products [] = {
 /*
@@ -618,6 +619,61 @@ static const struct usb_device_id	products [] = {
 	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
 	.driver_info = (unsigned long)&wwan_info,
 }, {
+	/* ZTE (Vodafone) K3805-Z */
+	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
+		 | USB_DEVICE_ID_MATCH_PRODUCT
+		 | USB_DEVICE_ID_MATCH_INT_INFO,
+	.idVendor               = ZTE_VENDOR_ID,
+	.idProduct		= 0x1003,
+	.bInterfaceClass	= USB_CLASS_COMM,
+	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
+	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	.driver_info = (unsigned long)&wwan_info,
+}, {
+	/* ZTE (Vodafone) K3806-Z */
+	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
+		 | USB_DEVICE_ID_MATCH_PRODUCT
+		 | USB_DEVICE_ID_MATCH_INT_INFO,
+	.idVendor               = ZTE_VENDOR_ID,
+	.idProduct		= 0x1015,
+	.bInterfaceClass	= USB_CLASS_COMM,
+	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
+	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	.driver_info = (unsigned long)&wwan_info,
+}, {
+	/* ZTE (Vodafone) K4510-Z */
+	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
+		 | USB_DEVICE_ID_MATCH_PRODUCT
+		 | USB_DEVICE_ID_MATCH_INT_INFO,
+	.idVendor               = ZTE_VENDOR_ID,
+	.idProduct		= 0x1173,
+	.bInterfaceClass	= USB_CLASS_COMM,
+	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
+	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	.driver_info = (unsigned long)&wwan_info,
+}, {
+	/* ZTE (Vodafone) K3770-Z */
+	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
+		 | USB_DEVICE_ID_MATCH_PRODUCT
+		 | USB_DEVICE_ID_MATCH_INT_INFO,
+	.idVendor               = ZTE_VENDOR_ID,
+	.idProduct		= 0x1177,
+	.bInterfaceClass	= USB_CLASS_COMM,
+	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
+	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	.driver_info = (unsigned long)&wwan_info,
+}, {
+	/* ZTE (Vodafone) K3772-Z */
+	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
+		 | USB_DEVICE_ID_MATCH_PRODUCT
+		 | USB_DEVICE_ID_MATCH_INT_INFO,
+	.idVendor               = ZTE_VENDOR_ID,
+	.idProduct		= 0x1181,
+	.bInterfaceClass	= USB_CLASS_COMM,
+	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
+	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	.driver_info = (unsigned long)&wwan_info,
+}, {
 	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_ETHERNET,
 			USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &cdc_info,
-- 
1.7.6.5
