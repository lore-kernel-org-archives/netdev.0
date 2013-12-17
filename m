From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-12-17
Date: Tue, 17 Dec 2013 12:01:51 +0100
Message-ID: <52B02F1F.6020702@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="V0DuMbVNmHQ9Qsx14VWWk0BGwUcF9kGwh"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--V0DuMbVNmHQ9Qsx14VWWk0BGwUcF9kGwh
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of four patches for net-next/master.

There is one patch by Markus Pargmann, which speeds up the c_can
driver, a patch by John Whitmore which updates the in tree
documentation. A patch by Jeff Kirsher which replaces the FSF's address
by a link and a patch by Alexander Shiyan which converts the mcp251x
driver to make use of managed resources.

regards,
Marc

---

The following changes since commit 89e47d3b8a273b0eac21e4bf6d7fdb86b654fa=
16:

  fddi: cleanup unsigned to unsigned int/short (2013-12-16 20:07:59 -0500=
)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 21629e1a118402566dce08f26edf19954fecef32:

  can: mcp251x: Convert to devm-* API (2013-12-17 11:47:21 +0100)

----------------------------------------------------------------
Alexander Shiyan (1):
      can: mcp251x: Convert to devm-* API

Jeff Kirsher (1):
      can: Fix FSF address in file headers

John Whitmore (1):
      can: update MAINTAINERS and Documentation

Markus Pargmann (1):
      can: c_can: Speed up rx_poll function

 Documentation/networking/can.txt              | 94 +++++++++++----------=
------
 MAINTAINERS                                   |  1 +
 drivers/net/can/c_can/c_can.c                 | 22 ++++---
 drivers/net/can/dev.c                         |  3 +-
 drivers/net/can/mcp251x.c                     | 22 ++-----
 drivers/net/can/mscan/mpc5xxx_can.c           |  3 +-
 drivers/net/can/mscan/mscan.c                 |  3 +-
 drivers/net/can/mscan/mscan.h                 |  3 +-
 drivers/net/can/pch_can.c                     |  3 +-
 drivers/net/can/sja1000/ems_pci.c             |  3 +-
 drivers/net/can/sja1000/kvaser_pci.c          |  3 +-
 drivers/net/can/sja1000/plx_pci.c             |  3 +-
 drivers/net/can/sja1000/sja1000_isa.c         |  3 +-
 drivers/net/can/sja1000/sja1000_of_platform.c |  3 +-
 drivers/net/can/sja1000/sja1000_platform.c    |  3 +-
 drivers/net/can/slcan.c                       |  4 +-
 drivers/net/can/softing/softing_cs.c          |  3 +-
 drivers/net/can/softing/softing_fw.c          |  3 +-
 drivers/net/can/softing/softing_main.c        |  3 +-
 19 files changed, 72 insertions(+), 113 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--V0DuMbVNmHQ9Qsx14VWWk0BGwUcF9kGwh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKwLyAACgkQjTAFq1RaXHOXjQCfbPfWxjpuws38TDa27b2CZjgh
e3YAn1lbfQm8DbBQyE8ITXsr2CHW/TJJ
=NSBM
-----END PGP SIGNATURE-----

--V0DuMbVNmHQ9Qsx14VWWk0BGwUcF9kGwh--
