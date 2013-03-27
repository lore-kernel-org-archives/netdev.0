From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-03-27
Date: Wed, 27 Mar 2013 15:18:32 +0100
Message-ID: <5152FFB8.2000008@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2RJNUOIUIARISJRLAWPDW"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2RJNUOIUIARISJRLAWPDW
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull-request for net-next/master. It consists of three
patches by Lars-Peter Clausen to clean up the mcp251x spi-can driver,
two patches from Ludovic Desroches to bring device tree support to the
at91_can driver and a patch by me to fix a sparse warning in the
blackfin driver.

regards,
Marc

---

The following changes since commit 6bdeaba47d87f48a3943b6899d6c6e6f17d52f=
1d:

  6lowpan: use IEEE802154_ADDR_LEN instead of a magic number (2013-03-27 =
00:52:16 -0400)

are available in the git repository at:

  git@gitorious.org:linux-can/linux-can-next.git testing

for you to fetch changes up to 21c11bc5d016ede062843cb3f98ee6824e6bcae2:

  can: bfin_can: declare locally used functions static (2013-03-27 13:07:=
10 +0100)

----------------------------------------------------------------
Lars-Peter Clausen (3):
      can: mcp251x: Remove redundant spi driver bus initialization
      can: mcp251x: Use module_spi_driver
      can: mcp251x: Use dev_pm_ops

Ludovic Desroches (2):
      can: at91_can: add dt support
      can: Kconfig: CAN_AT91 depends on ARM

Marc Kleine-Budde (1):
      can: bfin_can: declare locally used functions static

 .../devicetree/bindings/net/can/atmel-can.txt      | 14 ++++
 drivers/net/can/Kconfig                            |  2 +-
 drivers/net/can/at91_can.c                         | 76 ++++++++++++++++=
------
 drivers/net/can/bfin_can.c                         |  4 +-
 drivers/net/can/mcp251x.c                          | 35 ++++------
 5 files changed, 88 insertions(+), 43 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/atmel-can.t=
xt

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2RJNUOIUIARISJRLAWPDW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlFS/7sACgkQjTAFq1RaXHPeoQCghKvtEaEolSb14gGE3iGjPRRX
CXsAn2AhpX/27FYNhbk/AV3HzDJuxXPR
=WUs+
-----END PGP SIGNATURE-----

------enig2RJNUOIUIARISJRLAWPDW--
