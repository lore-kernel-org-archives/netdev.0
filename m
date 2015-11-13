From: Daniele Palmas <dnlplm@gmail.com>
Subject: [PATCH 1/1] net: usb: cdc_ether: add Dell DW5580 as a mobile broadband adapter
Date: Fri, 13 Nov 2015 18:01:21 +0100
Message-ID: <1447434081-19513-1-git-send-email-dnlplm@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Daniele Palmas <dnlplm@gmail.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34312 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932978AbbKMRCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 12:02:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since Dell DW5580 is a 3G modem, this patch adds the device as a
mobile broadband adapter

Signed-off-by: Daniele Palmas <dnlplm@gmail.com>
---
 drivers/net/usb/cdc_ether.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 35a2bff..5e92076 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -764,6 +764,11 @@ static const struct usb_device_id	products[] = {
 			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
 	.driver_info = (kernel_ulong_t) &wwan_info,
 }, {
+	/* Dell DW5580 modules */
+	USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, 0x81ba, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = (kernel_ulong_t)&wwan_info,
+}, {
 	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_ETHERNET,
 			USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &cdc_info,
-- 
1.9.1
