From: "Andrew Bird (Sphere Systems)" <ajb@spheresystems.co.uk>
Subject: Additional whitelist PID to the wwan whitelist in cdc_ether
Date: Sat, 16 Jan 2010 19:29:54 +0000
Message-ID: <201001161929.55504.ajb@spheresystems.co.uk>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_zOhULr14iJg0qtz"
To: davem@davemloft.net,
	Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.zen.co.uk ([212.23.3.27]:33390 "EHLO doppler.zen.co.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752273Ab0APTbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jan 2010 14:31:40 -0500
Received: from [212.23.3.141] (helo=smarthost02.mail.zen.net.uk)
	by doppler.zen.co.uk with esmtp (Exim 4.63)
	(envelope-from <ajb@spheresystems.co.uk>)
	id 1NWEN1-00032R-0G
	for netdev@vger.kernel.org; Sat, 16 Jan 2010 19:31:39 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_zOhULr14iJg0qtz
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Dave,
	I wonder if you might accept this patch to add an additional device to the 
wwan whitelist in the cdc_ether driver?

	In addition I wonder if the default interface flags are correct for wwan 
devices? I would have expected to have 'IFF_NOARP' and 'IFF_POINTTOPOINT' 
flags set, as this is essentially a ptp link that's not arp capable and 
broadcast makes no sense. In any case for me I always have to turn off arp 
with ifconfig to get any traffic through the device.


Best regards,


Andrew

--Boundary-00=_zOhULr14iJg0qtz
Content-Type: text/x-patch;
  charset="UTF-8";
  name="0001-Add-Vodafone-K3805-Z-wwan-device-to-cdc_ether-whitel.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-Add-Vodafone-K3805-Z-wwan-device-to-cdc_ether-whitel.patch"

=46rom 136ed09380319253b16c93fefd1e8b355430bf22 Mon Sep 17 00:00:00 2001
=46rom: Andrew Bird <ajb@spheresytems.co.uk>
Date: Sat, 16 Jan 2010 19:14:10 +0000
Subject: [PATCH] Add Vodafone K3805-Z wwan device to cdc_ether whitelist

=2D--
 drivers/net/usb/cdc_ether.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 21e183a..36a6c25 100644
=2D-- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -613,6 +613,11 @@ static const struct usb_device_id	products [] =3D {
 	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8184, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 	.driver_info =3D (unsigned long) &mbm_info,
+}, {
+	/* Vodafone K3805-Z (ZTE-Icera) */
+	USB_DEVICE_AND_INTERFACE_INFO(0x19d2, 0x1003, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info =3D (unsigned long) &mbm_info,
 },
 	{ },		// END
 };
=2D-=20
1.6.2.5


--Boundary-00=_zOhULr14iJg0qtz--
