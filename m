From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-08-22
Date: Thu, 22 Aug 2013 09:49:08 +0200
Message-ID: <5215C274.1090200@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="wrLs8lvFPX048hI3MC5N5lwhlxUrbnxqs"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wrLs8lvFPX048hI3MC5N5lwhlxUrbnxqs
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

another pull-request for net-next. It consists of two patches by Libo
Chen, the at91 and flexcan driver make use of platform_set_drvdata()
rather than open coding it. Chen Gang improves the error checking in
the c_can_platform driver's probe function.

regards,
Marc

---

The following changes since commit f8825669b3165bbf4380eabfd641f693d02af8=
66:

  net: phy: mdio-octeon: use platform_set_drvdata() (2013-08-21 20:51:11 =
-0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to d75ea942b360690a380da8012a51eaf6a6ebb1b1:

  can: flexcan: use platform_set_drvdata() (2013-08-22 09:40:20 +0200)

----------------------------------------------------------------
Chen Gang (1):
      can: c_can: fix error checking of priv->instance in probe()

Libo Chen (2):
      can: at91_can: use platform_set_drvdata()
      can: flexcan: use platform_set_drvdata()

 drivers/net/can/at91_can.c             | 2 +-
 drivers/net/can/c_can/c_can_platform.c | 2 +-
 drivers/net/can/flexcan.c              | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--wrLs8lvFPX048hI3MC5N5lwhlxUrbnxqs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIVwnQACgkQjTAFq1RaXHPBdgCgl1AT0kuJdtSJessNhsAy1cdx
XFYAn0jQJgfrV0h+KpXrlPWYe9xomeYG
=diSe
-----END PGP SIGNATURE-----

--wrLs8lvFPX048hI3MC5N5lwhlxUrbnxqs--
