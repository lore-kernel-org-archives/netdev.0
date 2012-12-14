From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] i2400m: add Intel 6150 device IDs
Date: Fri, 14 Dec 2012 17:10:50 -0600
Message-ID: <1355526650.32099.19.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: inaky.perez-gonzalez@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33946 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945993Ab2LNXJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 18:09:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add device IDs for WiMAX function of Intel 6150 cards.

Signed-off-by: Dan Williams <dcbw@redhat.com>
Cc: stable@vger.kernel.org
---
diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
index 6650fde..9f1e947 100644
--- a/drivers/net/wimax/i2400m/i2400m-usb.h
+++ b/drivers/net/wimax/i2400m/i2400m-usb.h
@@ -152,6 +152,9 @@ enum {
 	/* Device IDs */
 	USB_DEVICE_ID_I6050 = 0x0186,
 	USB_DEVICE_ID_I6050_2 = 0x0188,
+	USB_DEVICE_ID_I6150 = 0x07d6,
+	USB_DEVICE_ID_I6150_2 = 0x07d7,
+	USB_DEVICE_ID_I6150_3 = 0x07d9,
 	USB_DEVICE_ID_I6250 = 0x0187,
 };
 
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 713d033..080f363 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -510,6 +510,9 @@ int i2400mu_probe(struct usb_interface *iface,
 	switch (id->idProduct) {
 	case USB_DEVICE_ID_I6050:
 	case USB_DEVICE_ID_I6050_2:
+	case USB_DEVICE_ID_I6150:
+	case USB_DEVICE_ID_I6150_2:
+	case USB_DEVICE_ID_I6150_3:
 	case USB_DEVICE_ID_I6250:
 		i2400mu->i6050 = 1;
 		break;
@@ -759,6 +762,9 @@ static
 struct usb_device_id i2400mu_id_table[] = {
 	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6050) },
 	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6050_2) },
+	{ USB_DEVICE(0x8087, USB_DEVICE_ID_I6150) },
+	{ USB_DEVICE(0x8087, USB_DEVICE_ID_I6150_2) },
+	{ USB_DEVICE(0x8087, USB_DEVICE_ID_I6150_3) },
 	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6250) },
 	{ USB_DEVICE(0x8086, 0x0181) },
 	{ USB_DEVICE(0x8086, 0x1403) },
