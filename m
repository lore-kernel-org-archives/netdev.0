From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-05-16
Date: Thu, 16 May 2013 14:51:56 +0200
Message-ID: <5194D66C.8050502@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2IAKCXOXVTVXJXBBTBDSL"
To: Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2IAKCXOXVTVXJXBBTBDSL
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull-request for net-next/master. It consists of 4 patches by
Jingoo Han, which remove the unnecessary platform_set_drvdata() and a
patch by Laurent Navet converting the grcan driver to use
devm_ioremap_resource().

regards,
Marc

---

The following changes since commit dbbffe6898fd0d7bac66ded5d3c58835b13dde=
fc:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-05-=
13 13:25:36 -0700)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 5727dc6bf5b70dd278e58e26137e2df729b9c107:

  net: can: ti_hecc: remove unnecessary platform_set_drvdata() (2013-05-1=
6 13:27:20 +0200)

----------------------------------------------------------------
Jingoo Han (4):
      net: can: at91_can: remove unnecessary platform_set_drvdata()
      net: can: c_can: remove unnecessary platform_set_drvdata()
      net: can: flexcan: remove unnecessary platform_set_drvdata()
      net: can: ti_hecc: remove unnecessary platform_set_drvdata()

Laurent Navet (1):
      drivers: net: can: grcan: use devm_ioremap_resource()

 drivers/net/can/at91_can.c             | 2 --
 drivers/net/can/c_can/c_can_platform.c | 2 --
 drivers/net/can/flexcan.c              | 1 -
 drivers/net/can/grcan.c                | 7 +++----
 drivers/net/can/ti_hecc.c              | 1 -
 5 files changed, 3 insertions(+), 10 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2IAKCXOXVTVXJXBBTBDSL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGU1m8ACgkQjTAFq1RaXHOOyQCfSOzrlDgKive6NAY24T1Cjsy3
S4wAn0eDm1X7Y4OV++qFUnuVes9QIBq/
=xqaJ
-----END PGP SIGNATURE-----

------enig2IAKCXOXVTVXJXBBTBDSL--
