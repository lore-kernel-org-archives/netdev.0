From: Joerg Neikes <j.neikes@midlandgate.de>
Subject: Patch for Sitecom LN-031
Date: Fri, 09 Mar 2012 09:44:03 +0100
Message-ID: <1331282643.5426.6.camel@mobile>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the Sitecom LN-031 USB adapter with a AX88178 chip.

Added USB id to find correct driver for AX88178 1000 Ethernet adapter.

Signed-off-by: Joerg Neikes <j.neikes@midlandgate.de>



--- linux-3.2.6-gentoo/drivers/net/usb/asix.c	2012-02-14 14:54:11.079152551 +0100
+++ linux-3.2.9-gentoo/drivers/net/usb/asix.c	2012-03-09 00:01:34.657806558 +0100
@@ -1595,6 +1595,10 @@ static const struct usb_device_id	produc
 	USB_DEVICE (0x6189, 0x182d),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
+	// Sitecom LN-031 "USB 2.0 10/100/1000 Ethernet adapter"
+	USB_DEVICE (0x0df6, 0x0056),
+	.driver_info =  (unsigned long) &ax88178_info,
+}, {
 	// corega FEther USB2-TX
 	USB_DEVICE (0x07aa, 0x0017),
 	.driver_info =  (unsigned long) &ax8817x_info,




