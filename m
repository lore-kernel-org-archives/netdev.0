From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35] wimax/i2400m: Add PID & VID for Intel WiMAX 6250
Date: Thu, 22 Jul 2010 17:15:14 -0700
Message-ID: <41a8730c23aba4b77a13e5e151d2b69cd10ef6cb.1279843906.git.inaky.perez-gonzalez@intel.com>
References: <cover.1279843906.git.inaky.perez-gonzalez@intel.com>
Cc: Alexey Shvetsov <alexxy@gentoo.org>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:34290 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756194Ab0GWATv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 20:19:51 -0400
In-Reply-To: <cover.1279843906.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Shvetsov <alexxy@gentoo.org>

This version of intel wimax device was found in my IBM ThinkPad x201

Signed-off-by: Alexey Shvetsov <alexxy@gentoo.org>
---
 drivers/net/wimax/i2400m/i2400m-usb.h |    1 +
 drivers/net/wimax/i2400m/usb.c        |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
index 2d7c96d..eb80243 100644
--- a/drivers/net/wimax/i2400m/i2400m-usb.h
+++ b/drivers/net/wimax/i2400m/i2400m-usb.h
@@ -152,6 +152,7 @@ enum {
 	/* Device IDs */
 	USB_DEVICE_ID_I6050 = 0x0186,
 	USB_DEVICE_ID_I6050_2 = 0x0188,
+	USB_DEVICE_ID_I6250 = 0x0187,
 };
 
 
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 16341ff..0f88702 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -491,6 +491,7 @@ int i2400mu_probe(struct usb_interface *iface,
 	switch (id->idProduct) {
 	case USB_DEVICE_ID_I6050:
 	case USB_DEVICE_ID_I6050_2:
+	case USB_DEVICE_ID_I6250:
 		i2400mu->i6050 = 1;
 		break;
 	default:
@@ -739,6 +740,7 @@ static
 struct usb_device_id i2400mu_id_table[] = {
 	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6050) },
 	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6050_2) },
+	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6250) },
 	{ USB_DEVICE(0x8086, 0x0181) },
 	{ USB_DEVICE(0x8086, 0x1403) },
 	{ USB_DEVICE(0x8086, 0x1405) },
-- 
1.6.6.1

