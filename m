From: Daniele Palmas <dnlplm@gmail.com>
Subject: [PATCH 1/2] net: usb: cdc_ncm: Adding Dell DW5812 LTE Verizon Mobile Broadband Card
Date: Wed, 16 Dec 2015 10:39:24 +0100
Message-ID: <1450258765-11215-2-git-send-email-dnlplm@gmail.com>
References: <1450258765-11215-1-git-send-email-dnlplm@gmail.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Daniele Palmas <dnlplm@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36972 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754650AbbLPJkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 04:40:08 -0500
In-Reply-To: <1450258765-11215-1-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dell DW5812 is a mobile broadband card with no ARP capabilities: the patch
makes this device to use wwan_noarp_info struct

Signed-off-by: Daniele Palmas <dnlplm@gmail.com>
---
 drivers/net/usb/cdc_ncm.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index b45e5ca..2c0257a 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1593,6 +1593,13 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long) &wwan_info,
 	},
 
+	/* DW5812 LTE Verizon Mobile Broadband Card */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x81bb,
+		USB_CLASS_COMM,
+		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
+	  .driver_info = (unsigned long)&wwan_noarp_info,
+	},
+
 	/* Dell branded MBM devices like DW5550 */
 	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
 		| USB_DEVICE_ID_MATCH_VENDOR,
-- 
1.9.1
