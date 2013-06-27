From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-06-27
Date: Thu, 27 Jun 2013 15:23:34 +0200
Message-ID: <51CC3CD6.6050505@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2UADIOHJDRAJPHDBQRCTF"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2UADIOHJDRAJPHDBQRCTF
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull-request for net-next/master. It consists of three
patches by Fabio Estevam and me, which convert the flexcan transceiver
switching to DT[1] and a patch by Sachin Kamat, which cleans up the
at91_can driver a bit.

[1] These patches touch arch/arm/mach-imx, so I collected Acked-bys
from Shawn Guo and Sascha Hauer.

regards,
Marc

---

The following changes since commit 38ae92dc215e939897f17861d658f882d0eaab=
0f:

  fec: Add support for reading RMON registers (2013-06-26 15:45:14 -0700)=


are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 1f3e4b0cc4deb9d740261273fbbf5ea95c8434d0:

  can: at91_can: Use of_match_ptr() (2013-06-27 15:15:42 +0200)

----------------------------------------------------------------
Fabio Estevam (2):
      can: flexcan: Use a regulator to control the CAN transceiver
      ARM: imx: flexcan: Remove platform file

Marc Kleine-Budde (1):
      ARM: imx: prepare for removal of flexcan_platform_data

Sachin Kamat (1):
      can: at91_can: Use of_match_ptr()

 .../devicetree/bindings/net/can/fsl-flexcan.txt    |  2 +
 arch/arm/boot/dts/imx28-evk.dts                    | 12 ++++++
 arch/arm/mach-imx/devices-imx25.h                  |  8 ++--
 arch/arm/mach-imx/devices-imx35.h                  |  8 ++--
 arch/arm/mach-imx/devices/devices-common.h         |  4 +-
 arch/arm/mach-imx/devices/platform-flexcan.c       |  5 +--
 arch/arm/mach-imx/eukrea_mbimxsd25-baseboard.c     |  2 +-
 arch/arm/mach-imx/eukrea_mbimxsd35-baseboard.c     |  2 +-
 arch/arm/mach-imx/mach-mx25_3ds.c                  |  2 +-
 arch/arm/mach-imx/mach-pcm043.c                    |  2 +-
 arch/arm/mach-mxs/mach-mxs.c                       | 50 +---------------=
------
 drivers/net/can/at91_can.c                         |  4 +-
 drivers/net/can/flexcan.c                          | 25 +++++------
 include/linux/can/platform/flexcan.h               | 20 ---------
 14 files changed, 44 insertions(+), 102 deletions(-)
 delete mode 100644 include/linux/can/platform/flexcan.h
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2UADIOHJDRAJPHDBQRCTF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlHMPNYACgkQjTAFq1RaXHPAIACeKwT9+B75whQgDmJJvXFDkN77
bV0AnjtRxLojD4klCK8xo1U2aENlVDgB
=ETui
-----END PGP SIGNATURE-----

------enig2UADIOHJDRAJPHDBQRCTF--
