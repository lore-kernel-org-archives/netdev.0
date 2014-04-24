From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-04-25
Date: Fri, 25 Apr 2014 00:21:38 +0200
Message-ID: <53598E72.30504@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="3WJwwKqvxARgEeaLvgucdxgS8TDtr4AJG"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3WJwwKqvxARgEeaLvgucdxgS8TDtr4AJG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 10 patches for net-next/master.

It consists of three patches by Alexander Shiyan, which improve the
mcp251x driver. Stefano Babic's patch move the SPI driver into a sub
folder. The three patches by Olivier Sobrie add support for the Kvaser
Leaf v2 and usb mini PCIe hardware to the existing driver. Alexander
Stein contributes eg20t support to the c_can pci driver. Together with
the patches on the net-tree, we'll be able to remove the pch_can driver
soon. Kurt Van Dijck's two patches clean up the sysfs attributes of the
softing driver.

Marc

---

The following changes since commit 6afc0d7a85770abd282ebed41f0f35cde390d8=
61:

  bcm63xx_enet: Use ARRAY_SIZE instead of open coding it (2014-04-24 13:3=
8:57 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-fo=
r-3.16-20140425

for you to fetch changes up to 0f8dced5ef49159698a98f744e809a3fff32b827:

  can: softing: remove unused sysfs attributes (2014-04-25 00:09:03 +0200=
)

----------------------------------------------------------------
linux-can-next-for-3.16-20140425

----------------------------------------------------------------
Alexander Shiyan (3):
      can: mcp251x: Check return value of spi_setup()
      can: mcp251x: Improve mcp251x_hw_reset()
      can: mcp251x: Improve mcp251x_hw_probe()

Alexander Stein (1):
      can: c_can: Add support for eg20t (pch_can)

Kurt Van Dijck (2):
      can: softing: drop 'channel' sysfs attribute
      can: softing: remove unused sysfs attributes

Olivier Sobrie (3):
      can: kvaser_usb: add retries/timeout to kvaser_usb_wait_msg()
      can: kvaser_usb: add support for Kvaser Leaf v2 and usb mini PCIe
      can: usb: Kconfig: Improve help for CAN_KVASER_USB

Stefano Babic (1):
      can: move SPI drivers into a separate directory

 drivers/net/can/Kconfig                |  8 +--
 drivers/net/can/Makefile               |  2 +-
 drivers/net/can/c_can/c_can_pci.c      | 51 ++++++++++++++++++-
 drivers/net/can/softing/softing_main.c | 20 ++------
 drivers/net/can/spi/Kconfig            | 10 ++++
 drivers/net/can/spi/Makefile           |  8 +++
 drivers/net/can/{ =3D> spi}/mcp251x.c    | 93 ++++++++++++++++----------=
--------
 drivers/net/can/usb/Kconfig            |  4 +-
 drivers/net/can/usb/kvaser_usb.c       | 53 +++++++++++--------
 9 files changed, 154 insertions(+), 95 deletions(-)
 create mode 100644 drivers/net/can/spi/Kconfig
 create mode 100644 drivers/net/can/spi/Makefile
 rename drivers/net/can/{ =3D> spi}/mcp251x.c (96%)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |










--3WJwwKqvxARgEeaLvgucdxgS8TDtr4AJG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlNZjnIACgkQjTAFq1RaXHMHhQCggWNku/Rkzi5ONtxKubxCPjMu
hG8An1wUkQTMMMOOwu5H0SFA7dDhgrHa
=XWxF
-----END PGP SIGNATURE-----

--3WJwwKqvxARgEeaLvgucdxgS8TDtr4AJG--
