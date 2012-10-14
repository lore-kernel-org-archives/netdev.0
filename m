From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [PATCH] usb/ipheth: Add iPhone 5 support
Date: Sun, 14 Oct 2012 19:07:21 +0200
Message-ID: <1350234441-6262-1-git-send-email-jan.ceuleers@computer.org>
References: <20121011.171540.781078040657458587.davem@davemloft.net>
Cc: netdev@vger.kernel.org,
	Jay Purohit <jspurohit@velocitylimitless.com>,
	Valdis Kletnieks <valdis.kletnieks@vt.edu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:33616 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754510Ab2JNRKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 13:10:10 -0400
In-Reply-To: <20121011.171540.781078040657458587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Purohit <jspurohit@velocitylimitless.com>

I noticed that the iPhone ethernet driver did not support
iPhone 5. I quickly added support to it in my kernel, here's
a patch.

Signed-off-by: Jay Purohit <jspurohit@velocitylimitless.com>
Acked-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>
Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
---
Resubmitting on behalf of Jay, as he may have toolchain issues.

 drivers/net/usb/ipheth.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index a28a983..534d8be 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -62,6 +62,7 @@
 #define USB_PRODUCT_IPAD 0x129a
 #define USB_PRODUCT_IPHONE_4_VZW 0x129c
 #define USB_PRODUCT_IPHONE_4S	0x12a0
+#define USB_PRODUCT_IPHONE_5	0x12a8
 
 #define IPHETH_USBINTF_CLASS    255
 #define IPHETH_USBINTF_SUBCLASS 253
@@ -113,6 +114,10 @@ static struct usb_device_id ipheth_table[] = {
 		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_4S,
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
 		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_5,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
 	{ }
 };
 MODULE_DEVICE_TABLE(usb, ipheth_table);
-- 
1.7.9.5
