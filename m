From: Florian Schirmer <jolt@tuxbox.org>
Subject: [PATCH][0/4] b44: Cleanup and bcm47xx support
Date: Sun, 29 Aug 2004 22:17:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408292218.00756.jolt@tuxbox.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2614505.sLF7dPDoeK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2614505.sLF7dPDoeK
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

here is the second try to add bcm47xx support to the b44 driver. Changes si=
nce=20
the first version:

=2D Splitted the patch into logical hunks
=2D Ignore carrier lost errors (buggy hardware)
=2D Added CAM read support
=2D Read MAC from CAM instead of hardcoding a dummy MAC into the driver
=2D Use a special PHY address (0x30) to indicate that there is no PHY (this=
 is=20
compatible with the Broadcom et and 4401 driver)
=2D Added MDIO value calculation based on the backplane speed

Comments welcome!

Regards,
   Florian


--nextPart2614505.sLF7dPDoeK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBBMjn4XRF2vHoIlBsRAqt5AJ0TC4k2iZ+Fp26TqKAiaWX3bE9kKgCfRoar
zG5U7bJnHBbTiBSnk0f1z2M=
=kqcU
-----END PGP SIGNATURE-----

--nextPart2614505.sLF7dPDoeK--
