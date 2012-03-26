From: Guan Xin <guanx.bac@gmail.com>
Subject: [PATCH] USB: Add Motorola Rokr E6 Id to the USBNet driver "zaurus"
Date: Mon, 26 Mar 2012 16:11:46 +0200
Message-ID: <CANeMGR5PECuVb=p7orzwHgcsa9GSW=-gMyqWo7RYm_NpmLm4Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	Guan Xin <guanx.bac@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guan Xin <guanx.bac@gmail.com>

Added Vendor/Device Id of Motorola Rokr E6 (22b8:6027) so it can be
recognized by the "zaurus" USBNet driver.
Applies to Linux 3.2.13 and 2.6.39.4.
Signed-off-by: Guan Xin <guanx.bac@gmail.com>
---
--- a/drivers/net/usb/zaurus.c	2012-03-26 15:28:43.964244583 +0200
+++ b/drivers/net/usb/zaurus.c	2012-03-26 15:02:16.860801959 +0200
@@ -332,6 +332,11 @@ static const struct usb_device_id	produc
 	.driver_info = ZAURUS_PXA_INFO,
 },
 {
+	/* Motorola Rokr E6 */
+	USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x6027, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &bogus_mdlm_info,
+}, {
 	/* Motorola MOTOMAGX phones */
 	USB_DEVICE_AND_INTERFACE_INFO(0x22b8, 0x6425, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
