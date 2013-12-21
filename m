From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-12-22
Date: Sun, 22 Dec 2013 00:09:10 +0100
Message-ID: <52B61F96.2000408@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="R7rsUv4x7tp7DFudMe3BkOsln3AEDSgcf"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--R7rsUv4x7tp7DFudMe3BkOsln3AEDSgcf
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of three patches for net-next/master.

There is a patch by Oliver Hartkopp, to clean up the CAN gw code.
Alexander Shiyan adds device tree support to the mcp251x driver and a
patch by Ezequiel Garcia lets the ti_hecc driver compile on all ARM
platforms.

regards,
Marc

---

The following changes since commit ac7686b9698038cdf5148c9904db907448dcec=
a4:

  packet: doc: add documentation for VLAN TPID delivery (2013-12-21 00:01=
:40 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 44cc479a41c028a229c5491e9fa97df08901178b:

  can: ti_hecc: Replace platform dependency with ARM dependency (2013-12-=
22 00:03:51 +0100)

----------------------------------------------------------------
Alexander Shiyan (1):
      can: mcp251x: Add device tree support

Ezequiel Garcia (1):
      can: ti_hecc: Replace platform dependency with ARM dependency

Oliver Hartkopp (1):
      can: gw: remove obsolete checks

 .../bindings/net/can/microchip,mcp251x.txt         | 25 ++++++
 drivers/net/can/Kconfig                            |  2 +-
 drivers/net/can/mcp251x.c                          | 99 ++++++++++++++++=
------
 net/can/gw.c                                       |  6 +-
 4 files changed, 102 insertions(+), 30 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/microchip,m=
cp251x.txt

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |




--R7rsUv4x7tp7DFudMe3BkOsln3AEDSgcf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlK2H5YACgkQjTAFq1RaXHNRxgCeNtzWDW6fVxVQvmRmfQHRXdAg
QlwAnja7CoGzZVqFJwW33Ib6UsvavVfI
=A+1A
-----END PGP SIGNATURE-----

--R7rsUv4x7tp7DFudMe3BkOsln3AEDSgcf--
