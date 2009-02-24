From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] asix: new device ids
Date: Mon, 23 Feb 2009 16:08:46 -0800
Message-ID: <20090224000846.GA21368@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Armani Liao <aliao-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

This patch adds two new device ids to the asix driver.

One comes directly from the asix driver on their web site, the other was
reported by Armani Liao as needed for the MSI X320 to get the driver to
work properly for it.

Reported-by: Armani Liao <aliao-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>
Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

---
 drivers/net/usb/asix.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1451,6 +1451,14 @@ static const struct usb_device_id	produc
 	// Cables-to-Go USB Ethernet Adapter
 	USB_DEVICE(0x0b95, 0x772a),
 	.driver_info = (unsigned long) &ax88772_info,
+}, {
+	// ABOCOM for pci
+	USB_DEVICE(0x14ea, 0xab11),
+	.driver_info = (unsigned long) &ax88178_info,
+}, {
+	// ASIX 88772a
+	USB_DEVICE(0x0db0, 0xa877),
+	.driver_info = (unsigned long) &ax88772_info,
 },
 	{ },		// END
 };
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
