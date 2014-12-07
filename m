From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-12-07
Date: Mon, 08 Dec 2014 00:33:23 +0100
Message-ID: <5484E3C3.5030205@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KLItTqTtJe6Rcl3WirTIwnoFLWwIVist8"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KLItTqTtJe6Rcl3WirTIwnoFLWwIVist8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 8 patches for net-next/master.

Andri Yngvason contributes 4 patches in which the CAN state change
handling is consolidated and unified among the sja1000, mscan and
flexcan driver. The three patches by Jeremiah Mahler fix spelling
mistakes and eliminate the banner[] variable in various parts. And a
patch by me that switches on sparse endianess checking by default.

Marc

---

The following changes since commit 8d0c4697534a739725e429ff062dea393d8860=
d1:

  Merge branch 'ebpf-next' (2014-12-05 21:47:48 -0800)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-fo=
r-3.19-20141207

for you to fetch changes up to 71a3aedce6b37318d0e38676681dff179ec42874:

  can: flexcan: Consolidate and unify state change handling (2014-12-07 2=
1:22:10 +0100)

----------------------------------------------------------------
linux-can-next-for-3.19-20141207

----------------------------------------------------------------
Andri Yngvason (4):
      can: dev: Consolidate and unify state change handling
      can: sja1000: Consolidate and unify state change handling
      can: mscan: Consolidate and unify state change handling
      can: flexcan: Consolidate and unify state change handling

Jeremiah Mahler (3):
      can: eliminate banner[] variable and switch to pr_info()
      can: slcan/vcan: eliminate banner[] variable, switch to pr_info()
      can: fix spelling errors

Marc Kleine-Budde (1):
      can: Enable -D__CHECK_ENDIAN__ for sparse by default

 drivers/net/can/Makefile          |   3 +-
 drivers/net/can/cc770/cc770.c     |   2 +-
 drivers/net/can/dev.c             |  78 +++++++++++++++++++++++++++++
 drivers/net/can/flexcan.c         | 101 +++++++-------------------------=
------
 drivers/net/can/mscan/mscan.c     |  48 ++++++------------
 drivers/net/can/sja1000/sja1000.c |  51 +++++++++----------
 drivers/net/can/slcan.c           |   7 +--
 drivers/net/can/vcan.c            |   5 +-
 include/linux/can/dev.h           |   3 ++
 include/uapi/linux/can/error.h    |   1 +
 net/can/af_can.c                  |   7 +--
 net/can/bcm.c                     |  16 +++---
 net/can/gw.c                      |   2 +-
 net/can/raw.c                     |   4 +-
 14 files changed, 154 insertions(+), 174 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |




















--KLItTqTtJe6Rcl3WirTIwnoFLWwIVist8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUhOPDAAoJECte4hHFiupUmWoP/jjYMo3QsYjqXOHZmdVKU5P9
Wf2snha+e6ytIf8BNDRhgLYUN0Z2WEaLV1hQpFjF3AF2XPqiQ6v/S7D4tzo/oaiQ
gROIPMN1VFSAweYgyi+6Exy9hTSq3dKDCZcceri+KWST+zAB5JbTP3Mm16tpHCuR
XPH+YXj28wEzk/pIi+hMNDhUPb/+Gpe439s2BrtoB1eA+sj8MEJ+6EU2vodB9erY
4h7rbCT27a03KRVG+OJRnctVvMAUrPIlJ0mjpS3hgZM1ne4TWdWv+p+77aM34YnW
U4oiLgb7d70fsMUIY8IsvWSHr9fsWNHupeS/Q7B2THHk/H+ImM1ax5ZqwKTtQr/t
XfyH3gsp4BQw6ZBBTvegQjM98A8/h6vAqN0eZ+Evhj4+uOM+bExzNPWoyA0iHdJf
J4LGb9aB7bOdsOBPQj/g9IpVfh078UPrSlWd9yxDGjCPRzsZDxhLplkDaf07D6yr
mO72oxdKQU8Ej62SRGco52jPUapXBl9YiFX+ED6yfSJy6ohtdqYga1lDm83B+sw8
5vPaa/l2zY6vOiRVZHS+scFrgRXch8cg6gZPccrUSxNpP5p3rQrheL593WzZQi08
bQ7RyWqphbrlVik+/tFk22NZSRomeouwDQV5N2RoXoE387L+8MVXWQ7lgsO287Ww
ZTw8lXBFaTW6QlJ6EsAZ
=Ukhl
-----END PGP SIGNATURE-----

--KLItTqTtJe6Rcl3WirTIwnoFLWwIVist8--
