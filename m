From: Fabio Porcedda <fabio.porcedda@gmail.com>
Subject: [PATCH 1/3] net: usb: cdc_ether: Use wwan interface for Telit modules
Date: Mon, 16 Sep 2013 11:47:50 +0200
Message-ID: <1379324872-15944-2-git-send-email-fabio.porcedda@gmail.com>
References: <1379324872-15944-1-git-send-email-fabio.porcedda@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	<stable@vger.kernel.org>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36246 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309Ab3IPJsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 05:48:01 -0400
In-Reply-To: <1379324872-15944-1-git-send-email-fabio.porcedda@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabio Porcedda <fabio.porcedda@gmail.com>
Cc: <stable@vger.kernel.org> # 3.0+ as far back as it applies cleanly
---
 drivers/net/usb/cdc_ether.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 03ad4dc..98aef3b 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -726,6 +726,11 @@ static const struct usb_device_id	products [] = {
 	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
 	.driver_info = (unsigned long)&wwan_info,
 }, {
+	/* Telit modules */
+	USB_VENDOR_AND_INTERFACE_INFO(0x1bc7, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = (kernel_ulong_t) &wwan_info,
+}, {
 	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_ETHERNET,
 			USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &cdc_info,
-- 
1.8.4
