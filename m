From: =?iso-8859-1?Q?Jonas_Sj=F6quist?= <jonas.sjoquist@ericsson.com>
Subject: [PATCH -next] cdc_ether: additional PID's to the whitelist
Date: Thu, 18 Jun 2009 13:50:52 +0200
Message-ID: <94BF386B051B5849BA84A45DDFC4E60A05035C38@esealmw118.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "David Brownell" <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:60962 "EHLO
	mailgw3.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637AbZFRMFz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 08:05:55 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds five PID's to the whitelist set of devices.

Devices added to the whitelist:

Dell Wireless 5530 HSPA
Ericsson Mobile Broadband Module variants (F3507g, F3607gw and F3307)
Toshiba F3507g

Signed-off-by: Jonas Sj=F6quist <jonas.sjoquist@ericsson.com>

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 3717569..5a6797a 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -169,10 +169,12 @@ config USB_NET_CDCETHER
 	  The Linux-USB CDC Ethernet Gadget driver is an open implementation.
  	  This driver should work with at least the following devices:
=20
+ 	    * Dell Wireless 5530 HSPA
  	    * Ericsson PipeRider (all variants)
+ 	    * Ericsson Mobile Broadband Module (all variants)
  	    * Motorola (DM100 and SB4100)
  	    * Broadcom Cable Modem (reference design)
- 	    * Toshiba PCX1100U
+ 	    * Toshiba (PCX1100U and F3507g)
 	    * ...
=20
 	  This driver creates an interface named "ethX", where X depends on
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 01fd528..4a6aff5 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -533,6 +533,31 @@ static const struct usb_device_id	products [] =3D =
{
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
+}, {
+	/* Ericsson F3307 */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1906, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info =3D (unsigned long) &cdc_info,
+}, {
+	/* Toshiba F3507g */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130b, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info =3D (unsigned long) &cdc_info,
+}, {
+	/* Dell F3507g */
+	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8147, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info =3D (unsigned long) &cdc_info,
 },
 	{ },		// END
 };
