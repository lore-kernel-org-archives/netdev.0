From: Quinlan Pfiffer <qpfiffer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/1] Adds support for Lenovo 10/100 USB dongle.
Date: Fri, 28 Sep 2012 22:58:44 -0700
Message-ID: <1348898324-6550-1-git-send-email-qpfiffer@gmail.com>
Cc: Linux USB <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Networking Drivers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Quinlan Pfiffer <qpfiffer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This dongle ships with the X1 Carbon, and has an AX88772B
usb to ethernet chip in it.

Signed-off-by: Quinlan Pfiffer <qpfiffer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/asix_devices.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 32e31c5..fc20e53 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -930,6 +930,10 @@ static const struct usb_device_id	products [] = {
 	USB_DEVICE (0x04f1, 0x3008),
 	.driver_info = (unsigned long) &ax8817x_info,
 }, {
+	// Lenovo U2L100P 10/100
+	USB_DEVICE (0x17ef, 0x7203),
+	.driver_info = (unsigned long) &ax88772_info,
+}, {
 	// ASIX AX88772B 10/100
 	USB_DEVICE (0x0b95, 0x772b),
 	.driver_info = (unsigned long) &ax88772_info,
-- 
1.7.12.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
