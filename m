From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] bluetooth: document config options
Date: Fri, 21 Jul 2017 09:49:58 +0200
Message-ID: <20170721074957.GA12640@amd>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Cc: Netdev list <netdev@vger.kernel.org>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        linux-bluetooth@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Kernel config options should include useful help text; I had to look
up the terms on wikipedia.

Signed-off-by: Pavel Machek <pavel@ucw.cz>

diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
index 68f951b..133c8a6 100644
--- a/net/bluetooth/Kconfig
+++ b/net/bluetooth/Kconfig
@@ -45,6 +45,8 @@ config BT_BREDR
 	bool "Bluetooth Classic (BR/EDR) features"
 	depends on BT
 	default y
+	help
+	  Support Bluetooth version 1 and 2 connections.
=20
 source "net/bluetooth/rfcomm/Kconfig"
=20
@@ -58,11 +60,17 @@ config BT_HS
 	bool "Bluetooth High Speed (HS) features"
 	depends on BT_BREDR
 	default y
+	help
+	  Bluetooth 3 introduces high-speed mode where bluetooth endpoints
+	  negotiate fast connection over WIFI. This controls its support.
=20
 config BT_LE
 	bool "Bluetooth Low Energy (LE) features"
 	depends on BT
 	default y
+	help
+	  Bluetooth 4 introduces special low-energy protocol, designed
+	  for simple devices. This controls its support.
=20
 config BT_6LOWPAN
 	tristate "Bluetooth 6LoWPAN support"

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAllxsiUACgkQMOfwapXb+vLPFwCgjLHy066ynfZBotvzUJaFZsqu
KpkAoJvJ706dDACMKqewjy4uHvTeoWI8
=TzsD
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
