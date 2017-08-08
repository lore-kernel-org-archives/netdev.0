From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCHv2] bluetooth: document config options
Date: Tue, 8 Aug 2017 15:48:40 +0200
Message-ID: <20170808134839.GA801@amd>
References: <20170721074957.GA12640@amd>
 <CDF602D5-78C6-4F97-9C12-3E6AD3AA6C37@holtmann.org>
 <20170721104228.GA9448@amd>
 <EDDC23EF-C82E-41EE-8530-E86B9B4756A5@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        linux-bluetooth@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>,
        Netdev list <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDDC23EF-C82E-41EE-8530-E86B9B4756A5@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Kernel config options should include useful help text; I had to look
up the terms on wikipedia.

Signed-off-by: Pavel Machek <pavel@ucw.cz>

---

> are you planning to send a patch with updated wording for this?

Sorry for the delay, it is above. I added word "wifi" to 802.11
description.

							Pavel

diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
index 68f951b..48add1e 100644
--- a/net/bluetooth/Kconfig
+++ b/net/bluetooth/Kconfig
@@ -45,6 +45,11 @@ config BT_BREDR
 	bool "Bluetooth Classic (BR/EDR) features"
 	depends on BT
 	default y
+	help
+	  Bluetooth Classic includes support for Basic Rate (BR)
+	  available with Bluetooth version 1.0b or later and support
+	  for Enhanced Data Rate (EDR) available with Bluetooth
+	  version 2.0 or later.
=20
 source "net/bluetooth/rfcomm/Kconfig"
=20
@@ -58,12 +63,19 @@ config BT_HS
 	bool "Bluetooth High Speed (HS) features"
 	depends on BT_BREDR
 	default y
+	help
+	  Bluetooth High Speed includes support for off-loading
+	  Bluetooth connections via 802.11 (wifi) physical layer
+	  available with Bluetooth version 3.0 or later.
=20
 config BT_LE
 	bool "Bluetooth Low Energy (LE) features"
 	depends on BT
 	default y
-
+	help
+	  Bluetooth Low Energy includes support low-energy physical
+	  layer available with Bluetooth version 4.0 or later.
+	 =20
 config BT_6LOWPAN
 	tristate "Bluetooth 6LoWPAN support"
 	depends on BT_LE && 6LOWPAN

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmJwTcACgkQMOfwapXb+vIYEQCeJr6pC+SAN72Ys0OhbqMeZ6M8
ookAnjJ0wMqlM2f7x2sd55JleyIyXUNq
=w1QS
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
