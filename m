From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 12/32] rt2x00: Add USB ID's
Date: Fri, 28 Apr 2006 00:03:03 +0200
Message-ID: <200604280003.03960.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1300970.FuRfZkjWzk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.184]:37997 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751788AbWD0WCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:00 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463914nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:58 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1300970.FuRfZkjWzk
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Remove the rt73usb ID that accidently sneaked into
rt2500usb. And add new rt2500usb ID's.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:42:29.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:44:33.000000000 +0200
@@ -2192,6 +2192,7 @@ static struct usb_device_id rt2500usb_de
 	{ USB_DEVICE(0x0b05, 0x1707), .driver_info =3D RT2570},
 	/* Belkin */
 	{ USB_DEVICE(0x050d, 0x7050), .driver_info =3D RT2570},
+	{ USB_DEVICE(0x050d, 0x7051), .driver_info =3D RT2570},
 	{ USB_DEVICE(0x050d, 0x705a), .driver_info =3D RT2570},
 	/* Cisco Systems */
 	{ USB_DEVICE(0x13b1, 0x000d), .driver_info =3D RT2570},
@@ -2201,7 +2202,6 @@ static struct usb_device_id rt2500usb_de
 	{ USB_DEVICE(0x14b2, 0x3c02), .driver_info =3D RT2570},
 	/* D-LINK */
 	{ USB_DEVICE(0x2001, 0x3c00), .driver_info =3D RT2570},
=2D	{ USB_DEVICE(0x07d1, 0x3c03), .driver_info =3D RT2570},
 	/* Gigabyte */
 	{ USB_DEVICE(0x1044, 0x8001), .driver_info =3D RT2570},
 	{ USB_DEVICE(0x1044, 0x8007), .driver_info =3D RT2570},
@@ -2224,6 +2224,10 @@ static struct usb_device_id rt2500usb_de
 	{ USB_DEVICE(0x0707, 0xee13), .driver_info =3D RT2570},
 	/* Spairon */
 	{ USB_DEVICE(0x114b, 0x0110), .driver_info =3D RT2570},
+	/* Trust */
+	{ USB_DEVICE(0x0eb0, 0x9020), .driver_info =3D RT2570},
+	/* Zinwell */
+	{ USB_DEVICE(0x5a57, 0x0260), .driver_info =3D RT2570},
 	{0,}
 };
=20

--nextPart1300970.FuRfZkjWzk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+XaqndE37Em0gRAjjzAJ4j4aWQ6gnsK6AGZmTYsk8mb1J3WwCfTBR3
GWmBjAu99MYoxAt3P9rut5I=
=NWEY
-----END PGP SIGNATURE-----

--nextPart1300970.FuRfZkjWzk--
