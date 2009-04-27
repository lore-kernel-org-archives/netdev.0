From: =?iso-8859-1?Q?Jonas_Sj=F6quist?= <jonas.sjoquist@ericsson.com>
Subject: [PATCH] additional PID's to be handled by cdc_ether
Date: Mon, 27 Apr 2009 09:28:14 +0200
Message-ID: <94BF386B051B5849BA84A45DDFC4E60A04AE6229@esealmw118.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:56738 "EHLO
	mailgw4.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbZD0HnS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 03:43:18 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a patch which adds two PID's to the Whitelist set of devices han=
dled by cdc_ether. The F3507g modules can have two different PID's indi=
cating hardware revision.

The F3607gw module is a wake-on wireless HSPA module.

This patch applies to kernel 2.6.29.1

Signed-off-by: Jonas Sj=F6quist <jonas.sjoquist@ericsson.com>

--- linux-2.6.29.1/drivers/net/usb/cdc_ether.c.orig	2009-04-23 14:07:10=
=2E000000000 +0200
+++ linux-2.6.29.1/drivers/net/usb/cdc_ether.c	2009-04-23 13:54:54.0000=
00000 +0200
@@ -560,10 +560,20 @@ static const struct usb_device_id	produc
 			USB_CDC_PROTO_NONE),
 	.driver_info =3D (unsigned long) &cdc_info,
 }, {
-	/* Ericsson F3507g */
+	/* Ericsson F3507g ver. 1 */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1900, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 	.driver_info =3D (unsigned long) &cdc_info,
+}, {
+	/* Ericsson F3507g ver. 2 */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1902, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info =3D (unsigned long) &cdc_info,
+}, {
+	/* Ericsson F3607gw */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1904, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info =3D (unsigned long) &cdc_info,
 },
 	{ },		// END
 };
