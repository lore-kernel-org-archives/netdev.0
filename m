From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-03-17
Date: Mon, 17 Mar 2014 10:37:23 +0100
Message-ID: <5326C253.2080102@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="VaiQuPpAbRHh5oWFlN6I0p9hbEqBi16Tm"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VaiQuPpAbRHh5oWFlN6I0p9hbEqBi16Tm
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of three patches for net-next/master.

It consists of a patch by Oliver Hartkopp, which unifies the MTU
settings for CAN interfaces. A patch by Christopher R. Baker populates
netdev::dev_id for udev discrimination for multi interface CAN devices.
Alexander Shiyan contributes a patch for the mcp251x driver which fixes
the regulators operation if CONFIG_REGULATOR is not enabled.

Marc

---

The following changes since commit e7ef085d0a9dc1cc72e7d8108ed3b4e1a5e8d9=
38:

  Merge branch 'napi_budget_zero' (2014-03-14 22:53:35 -0400)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-fo=
r-3.15-20140317

for you to fetch changes up to 76aeec83e448478838eec868066dda33049d1288:

  can: mcp251x: Fix regulators operation without CONFIG_REGULATOR (2014-0=
3-17 09:20:17 +0100)

----------------------------------------------------------------
linux-can-next-for-3.15-20140317

----------------------------------------------------------------
Alexander Shiyan (1):
      can: mcp251x: Fix regulators operation without CONFIG_REGULATOR

Christopher R. Baker (1):
      can: populate netdev::dev_id for udev discrimination

Oliver Hartkopp (1):
      can: Unify MTU settings for CAN interfaces

 drivers/net/can/at91_can.c                   | 1 +
 drivers/net/can/bfin_can.c                   | 1 +
 drivers/net/can/c_can/c_can.c                | 1 +
 drivers/net/can/cc770/cc770.c                | 1 +
 drivers/net/can/flexcan.c                    | 1 +
 drivers/net/can/grcan.c                      | 1 +
 drivers/net/can/janz-ican3.c                 | 1 +
 drivers/net/can/mcp251x.c                    | 5 +++--
 drivers/net/can/mscan/mscan.c                | 7 ++++---
 drivers/net/can/pch_can.c                    | 1 +
 drivers/net/can/sja1000/ems_pci.c            | 1 +
 drivers/net/can/sja1000/ems_pcmcia.c         | 1 +
 drivers/net/can/sja1000/kvaser_pci.c         | 1 +
 drivers/net/can/sja1000/peak_pci.c           | 1 +
 drivers/net/can/sja1000/peak_pcmcia.c        | 1 +
 drivers/net/can/sja1000/plx_pci.c            | 1 +
 drivers/net/can/sja1000/sja1000.c            | 7 ++++---
 drivers/net/can/slcan.c                      | 6 ++++++
 drivers/net/can/softing/softing_main.c       | 2 ++
 drivers/net/can/ti_hecc.c                    | 1 +
 drivers/net/can/usb/ems_usb.c                | 1 +
 drivers/net/can/usb/esd_usb2.c               | 2 ++
 drivers/net/can/usb/kvaser_usb.c             | 2 ++
 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 2 ++
 drivers/net/can/usb/usb_8dev.c               | 1 +
 25 files changed, 42 insertions(+), 8 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |








--VaiQuPpAbRHh5oWFlN6I0p9hbEqBi16Tm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMmwlYACgkQjTAFq1RaXHMI/QCffYQBuenZ9n1fAXU2UIIytnTX
aVgAn1zAbuiw+natYZM3QbUyGNNJP5JS
=peNP
-----END PGP SIGNATURE-----

--VaiQuPpAbRHh5oWFlN6I0p9hbEqBi16Tm--
