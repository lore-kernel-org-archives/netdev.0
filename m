From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-06-03
Date: Mon, 03 Jun 2013 14:30:26 +0200
Message-ID: <51AC8C62.5010905@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2XKGBPAPUKTLUEDMXKDPL"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2XKGBPAPUKTLUEDMXKDPL
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull-request for net-next/master. It consists of two patches
by Fabio Estevam, cleaning up the flexcan driver (remove default
pinctrl and switch to SIMPLE_DEV_PM_OPS). A patch by me to simplify the
Kconfig [1] handling for flexcan. And a patch by Jingoo Han that
converts the can drivers to use platform_{get,set}_drvdata().

[1] My patch touches arch/{arm,powerpc}, so I collected Acked-bys from
Arnd Bergmann, Shawn Guo and Benjamin Herrenschmidt.

regards,
Marc

---
The following changes since commit 5865fc1b6a99bc7dcf245770c2735577b8596b=
6e:

  tg3: remove redundant pm init code (2013-06-03 00:48:11 -0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 00e4bbc8cd7efac66caa4ce6bcf5f02e944184f6:

  net: can: use platform_{get,set}_drvdata() (2013-06-03 13:13:49 +0200)

----------------------------------------------------------------
Fabio Estevam (2):
      can: flexcan: Let device core handle pinctrl
      can: flexcan: Use SIMPLE_DEV_PM_OPS

Jingoo Han (1):
      net: can: use platform_{get,set}_drvdata()

Marc Kleine-Budde (1):
      can: flexcan: remove HAVE_CAN_FLEXCAN Kconfig symbol

 arch/arm/mach-imx/Kconfig                     |  4 ----
 arch/arm/mach-imx/devices/Kconfig             |  1 -
 arch/arm/mach-mxs/Kconfig                     |  1 -
 arch/powerpc/Kconfig                          |  1 -
 drivers/net/can/Kconfig                       |  5 +----
 drivers/net/can/bfin_can.c                    | 10 ++++------
 drivers/net/can/cc770/cc770_isa.c             |  5 ++---
 drivers/net/can/cc770/cc770_platform.c        |  4 ++--
 drivers/net/can/flexcan.c                     | 26 +++++++++------------=
-----
 drivers/net/can/grcan.c                       |  5 ++---
 drivers/net/can/mscan/mpc5xxx_can.c           | 10 ++++------
 drivers/net/can/sja1000/sja1000_isa.c         |  5 ++---
 drivers/net/can/sja1000/sja1000_of_platform.c |  6 ++----
 drivers/net/can/sja1000/sja1000_platform.c    |  5 ++---
 14 files changed, 30 insertions(+), 58 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2XKGBPAPUKTLUEDMXKDPL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGsjGYACgkQjTAFq1RaXHNUuACfbwLvkXfIV1kdmijZBD3IrZFN
fosAnAqwz8u1TlIw9kFy73k1s8x7FbvC
=hWoc
-----END PGP SIGNATURE-----

------enig2XKGBPAPUKTLUEDMXKDPL--
