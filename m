From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2012-11-15
Date: Thu, 15 Nov 2012 21:30:27 +0100
Message-ID: <50A550E3.4060600@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA3B35DEF76B4057DA08160B3"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA3B35DEF76B4057DA08160B3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David

this pull request is for net-next, for the v3.8 release cycle. Muhammad
Ghias added support another board to the plx_pci sja1000 driver.
Matthias Fuchs improved the esd_usb2 driver with listen-only mode and
CAN-USB/Micro support. Andreas Larsson contributed a driver for the
GRHCAN CAN IP-Core

regards,
Marc

---

The following changes since commit 702ed3c1a9dfe4dfe112f13542d0c9d689f500=
8b:

  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge=
 (2012-11-14 22:10:50 -0500)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 6cec9b07fe6a0c4dfbcdcee7c6283529f087c521:

  can: grcan: Add device driver for GRCAN and GRHCAN cores (2012-11-15 20=
:47:26 +0100)

----------------------------------------------------------------
Andreas Larsson (1):
      can: grcan: Add device driver for GRCAN and GRHCAN cores

Chuansheng Liu (1):
      can: janz-ican3: Fix the usage of wait_for_completion_timeout

Matthias Fuchs (2):
      can: usb: esd_usb2: Add support for listen-only mode
      can: usb: esd_usb2: Add support for CAN-USB/Micro

Muhammad Ghias (1):
      can: sja1000: plx_pci: add support for Connect Tech Inc's Canpro/10=
4-Plus Opto CAN board

 Documentation/ABI/testing/sysfs-class-net-grcan    |   35 +
 .../devicetree/bindings/net/can/grcan.txt          |   28 +
 Documentation/kernel-parameters.txt                |   18 +
 drivers/net/can/Kconfig                            |    9 +
 drivers/net/can/Makefile                           |    1 +
 drivers/net/can/grcan.c                            | 1756 ++++++++++++++=
++++++
 drivers/net/can/janz-ican3.c                       |    4 +-
 drivers/net/can/sja1000/Kconfig                    |    1 +
 drivers/net/can/sja1000/plx_pci.c                  |   19 +
 drivers/net/can/usb/esd_usb2.c                     |   35 +-
 10 files changed, 1898 insertions(+), 8 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-grcan
 create mode 100644 Documentation/devicetree/bindings/net/can/grcan.txt
 create mode 100644 drivers/net/can/grcan.c

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigA3B35DEF76B4057DA08160B3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlClUOkACgkQjTAFq1RaXHOqawCeP8+mnHA18h4HkTvtaWjx2fEI
42MAn3HfoB1f9KUS08Atq7v3Tnwnx1eQ
=FmO+
-----END PGP SIGNATURE-----

--------------enigA3B35DEF76B4057DA08160B3--
