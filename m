From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-08-01
Date: Thu, 01 Aug 2013 14:00:24 +0200
Message-ID: <51FA4DD8.1040903@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="UEijNQR3C2PEhaXBtb2IVx48wkk72aw0Q"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--UEijNQR3C2PEhaXBtb2IVx48wkk72aw0Q
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull-request for net-next/master. It consists of two patches
by Fabio Estevam. Them first convert the flexcan driver to use
devm_ioremap_resource(), the second adds return value checking for
clk_prepare_enable().

regards,
Marc

---

The following changes since commit 46b3a421903aa2a4bc9731ca4663cee3ea869d=
ab:

  ipv6: fib6_rules should return exact return value (2013-08-01 00:26:22 =
-0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to aa10181bdac99a623517f0f2bfa14cd98c749246:

  can: flexcan: Check the return value from clk_prepare_enable() (2013-08=
-01 12:36:20 +0200)

----------------------------------------------------------------
Fabio Estevam (2):
      can: flexcan: Use devm_ioremap_resource()
      can: flexcan: Check the return value from clk_prepare_enable()

 drivers/net/can/flexcan.c | 81 +++++++++++++++++++----------------------=
------
 1 file changed, 32 insertions(+), 49 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--UEijNQR3C2PEhaXBtb2IVx48wkk72aw0Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlH6TdkACgkQjTAFq1RaXHMkpgCglZ6mMr0ZHOFglE6yBXKoB98i
aq4AoIlne63JaE6G0p685o/qqhYleeO8
=q8tJ
-----END PGP SIGNATURE-----

--UEijNQR3C2PEhaXBtb2IVx48wkk72aw0Q--
