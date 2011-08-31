From: Kavan Smith <kavansmith82-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] iPhone 4 Verizon CDMA USB Product ID add
Date: Wed, 31 Aug 2011 08:12:05 -0700
Message-ID: <1314803525-3451-1-git-send-email-kavansmith82@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kavan Smith <kavansmith82-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add USB product ID for iPhone 4 CDMA Verizon
Tested on at least 2 devices

Signed-off-by: Kavan Smith <kavansmith82-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---
 drivers/net/usb/ipheth.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index 15772b1..13c1f04 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -59,6 +59,7 @@
 #define USB_PRODUCT_IPHONE_3G   0x1292
 #define USB_PRODUCT_IPHONE_3GS  0x1294
 #define USB_PRODUCT_IPHONE_4	0x1297
+#define USB_PRODUCT_IPHONE_4_VZW 0x129c
 
 #define IPHETH_USBINTF_CLASS    255
 #define IPHETH_USBINTF_SUBCLASS 253
@@ -98,6 +99,10 @@ static struct usb_device_id ipheth_table[] = {
 		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_4,
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
 		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_4_VZW,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
 	{ }
 };
 MODULE_DEVICE_TABLE(usb, ipheth_table);
-- 
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
