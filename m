From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-07-15
Date: Tue, 15 Jul 2014 09:44:18 +0200
Message-ID: <53C4DBD2.8010309@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="SrvoRqa5b1HcG5sVBLlT9mktXAxfp8uIC"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SrvoRqa5b1HcG5sVBLlT9mktXAxfp8uIC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 4 patches for net-next/master.

Prabhakar Lad contributes a patch that converts the c_can driver to use
the devm api. The remaining four patches by Nikita Edward Baruzdin
improve the SJA1000 driver with loopback testing support and introduce
a new testing mode presume ack, for successful transmission even if no
ACK is received.

Marc

---

The following changes since commit 0854a7f13206d7523abe773235bbe4d13958fc=
4b:

  Merge branch 'amd811e-cleanups' (2014-07-14 19:14:44 -0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-fo=
r-3.17-20140715

for you to fetch changes up to 5b853ec3494e34eb4882f65ebbcd04b495ff3c85:

  can: sja1000: Add support for CAN_CTRLMODE_PRESUME_ACK (2014-07-15 09:3=
4:27 +0200)

----------------------------------------------------------------
linux-can-next-for-3.17-20140715

----------------------------------------------------------------
Lad, Prabhakar (1):
      can: c_can: convert to use devm * api

Nikita Edward Baruzdin (4):
      can: netlink: Remove space before tab
      can: netlink: Add CAN_CTRLMODE_PRESUME_ACK flag
      can: sja1000: Add support for CAN_CTRLMODE_LOOPBACK
      can: sja1000: Add support for CAN_CTRLMODE_PRESUME_ACK

 drivers/net/can/c_can/c_can_platform.c | 43 ++++++++--------------------=
------
 drivers/net/can/sja1000/sja1000.c      | 27 ++++++++++++++-------
 include/uapi/linux/can/netlink.h       |  3 ++-
 3 files changed, 31 insertions(+), 42 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |














--SrvoRqa5b1HcG5sVBLlT9mktXAxfp8uIC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlPE29IACgkQjTAFq1RaXHPtcACgkfKiKy6HkFOj8pDYkP6b+Nml
gjAAnjShsKF4DjoBcshAZqrjo/u3tDoQ
=qK4j
-----END PGP SIGNATURE-----

--SrvoRqa5b1HcG5sVBLlT9mktXAxfp8uIC--
