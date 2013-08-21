From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-08-21
Date: Wed, 21 Aug 2013 09:42:55 +0200
Message-ID: <52146F7F.6010001@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="OBJMXlfAeKdhUlBugQjW11apdbQF8FaiS"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OBJMXlfAeKdhUlBugQjW11apdbQF8FaiS
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this pull-request for net-next consists of a series by Alexander
Shiyan, he cleans up the mcp251x driver. As the first patch touches
arch/arm/mach-pxa, it's acked by Haojian Zhuang.

regards,
Marc

---

The following changes since commit 954c396756e3d31985f7bc6a414a988a4736a7=
d0:

  net/phy: micrel: Add OF configuration support for ksz9021 (2013-08-21 0=
0:03:38 -0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to b1ef05a5a20afe50d4188a5b59579bd140758cf0:

  can: mcp251x: Allow tuning SPI mode and limit maximal SPI speed (2013-0=
8-21 09:28:29 +0200)

----------------------------------------------------------------
Alexander Shiyan (3):
      can: mcp251x: Replace power callbacks with regulator API
      can: mcp251x: Eliminate irq_flags from driver platform_data
      can: mcp251x: Allow tuning SPI mode and limit maximal SPI speed

 arch/arm/mach-pxa/icontrol.c         |  3 --
 arch/arm/mach-pxa/zeus.c             | 46 +++++++++--------
 drivers/net/can/mcp251x.c            | 98 ++++++++++++++++++------------=
------
 include/linux/can/platform/mcp251x.h | 15 +-----
 4 files changed, 75 insertions(+), 87 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--OBJMXlfAeKdhUlBugQjW11apdbQF8FaiS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIUb38ACgkQjTAFq1RaXHN45wCfYk34pGy3oaAU8Qro9UNDlCh4
4BcAn0CaNhb/hcB1T70lrLys6b9Upfqx
=fXZS
-----END PGP SIGNATURE-----

--OBJMXlfAeKdhUlBugQjW11apdbQF8FaiS--
