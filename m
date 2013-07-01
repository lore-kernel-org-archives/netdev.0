From: Aaron Marburg <amarburg-MtqYO9m3oizKBv0CESTyP2D2FQJk+8+b@public.gmane.org>
Subject: [PATCH] net: ipheth:  Add USB ID for iPad mini
Date: Tue, 2 Jul 2013 10:00:06 +1200
Message-ID: <20130701220006.GB10209@mahimahi.notetofutureself.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amarburg-MtqYO9m3oizKBv0CESTyP2D2FQJk+8+b@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	diego-KR0zwsgql1HQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Adds the USB device ID (0x12ab) to the ipheth network-over-USB-tethering
driver for iOS devices.  Applied and tested against mainline tag v3.10
(as well as 3.8.x and 3.6.y kernel for Raspbian on Raspberry pi)


Signed-off-by: Aaron Marburg <amarburg-MtqYO9m3oizKBv0CESTyP2D2FQJk+8+b@public.gmane.org>

---


diff -upr -X linux-3.10.pristine/Documentation/dontdiff linux-3.10.pristine/drivers/net/usb/ipheth.c linux-3.10.ipheth/drivers/net/usb/ipheth.c
--- linux-3.10.pristine/drivers/net/usb/ipheth.c	2013-07-01 21:28:56.577106633 +1200
+++ linux-3.10.ipheth/drivers/net/usb/ipheth.c	2013-07-01 21:31:31.021102411 +1200
@@ -60,6 +60,7 @@
 #define USB_PRODUCT_IPHONE_3GS  0x1294
 #define USB_PRODUCT_IPHONE_4	0x1297
 #define USB_PRODUCT_IPAD 0x129a
+#define USB_PRODUCT_IPAD_MINI    0x12ab
 #define USB_PRODUCT_IPHONE_4_VZW 0x129c
 #define USB_PRODUCT_IPHONE_4S	0x12a0
 #define USB_PRODUCT_IPHONE_5	0x12a8
@@ -107,6 +108,10 @@ static struct usb_device_id ipheth_table
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
 		IPHETH_USBINTF_PROTO) },
 	{ USB_DEVICE_AND_INTERFACE_INFO(
+		USB_VENDOR_APPLE, USB_PRODUCT_IPAD_MINI,
+		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
+		IPHETH_USBINTF_PROTO) },
+	{ USB_DEVICE_AND_INTERFACE_INFO(
 		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE_4_VZW,
 		IPHETH_USBINTF_CLASS, IPHETH_USBINTF_SUBCLASS,
 		IPHETH_USBINTF_PROTO) },
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
