From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-09-21
Date: Sat, 21 Sep 2013 15:54:54 +0200
Message-ID: <523DA52E.2030701@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="qArC94PpuLXbB58GN8gkQRUVC08RnTQgs"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qArC94PpuLXbB58GN8gkQRUVC08RnTQgs
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request for net-next. It consists of two patches by Uwe
Kleine-K=C3=B6nig, they add explicit copyrights to the uapi CAN headers
(including Acked-bys of the header authors). And 12 cleanup patches by
Jingoo Han. Several drivers are converted to use dev_get_platdata()
instead of open coding it, two unnecessary pci_set_drvdata() are
removed from the CAN PCI drivers.

regards,
Marc

---

The following changes since commit 19717d05848849a3b1dddeced9abb5884cff91=
52:

  declance: Remove `incompatible pointer type' warnings (2013-09-20 14:41=
:03 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to a0c7d83322521880caf8c9c1ef20a2a1cd5cb955:

  can: sja1000: remove unnecessary pci_set_drvdata() (2013-09-21 15:43:16=
 +0200)

----------------------------------------------------------------
Jingoo Han (12):
      can: at91_can: use dev_get_platdata()
      can: bfin_can: use dev_get_platdata()
      can: cc770: use dev_get_platdata()
      can: flexcan: use dev_get_platdata()
      can: janz-ican3: use dev_get_platdata()
      can: mcp251x: use dev_get_platdata()
      can: sja1000: use dev_get_platdata()
      can: softing: use dev_get_platdata()
      can: ti_hecc: use dev_get_platdata()
      can: c_can: remove unnecessary pci_set_drvdata()
      can: pch_can: remove unnecessary pci_set_drvdata()
      can: sja1000: remove unnecessary pci_set_drvdata()

Uwe Kleine-K=C3=B6nig (2):
      can: add explicit copyrights to can headers
      can: add explicit copyrights to can's netlink header

 drivers/net/can/at91_can.c                 |  2 +-
 drivers/net/can/bfin_can.c                 |  2 +-
 drivers/net/can/c_can/c_can_pci.c          |  2 --
 drivers/net/can/cc770/cc770_platform.c     |  4 ++--
 drivers/net/can/flexcan.c                  |  2 +-
 drivers/net/can/janz-ican3.c               |  2 +-
 drivers/net/can/mcp251x.c                  |  2 +-
 drivers/net/can/pch_can.c                  |  1 -
 drivers/net/can/sja1000/ems_pci.c          |  1 -
 drivers/net/can/sja1000/kvaser_pci.c       |  1 -
 drivers/net/can/sja1000/peak_pci.c         |  2 --
 drivers/net/can/sja1000/plx_pci.c          |  1 -
 drivers/net/can/sja1000/sja1000_platform.c |  2 +-
 drivers/net/can/softing/softing_main.c     |  2 +-
 drivers/net/can/ti_hecc.c                  |  2 +-
 include/uapi/linux/can/bcm.h               | 32 ++++++++++++++++++++++++=
++++++
 include/uapi/linux/can/error.h             | 32 ++++++++++++++++++++++++=
++++++
 include/uapi/linux/can/gw.h                | 32 ++++++++++++++++++++++++=
++++++
 include/uapi/linux/can/netlink.h           |  8 ++++++++
 include/uapi/linux/can/raw.h               | 32 ++++++++++++++++++++++++=
++++++
 20 files changed, 146 insertions(+), 18 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--qArC94PpuLXbB58GN8gkQRUVC08RnTQgs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlI9pS4ACgkQjTAFq1RaXHOhCgCdFnOcHgEtZlXYce/NKIzjPqGG
SPIAoIoVV3fhAXMlGSK97LnfLqBniGaY
=MPrb
-----END PGP SIGNATURE-----

--qArC94PpuLXbB58GN8gkQRUVC08RnTQgs--
