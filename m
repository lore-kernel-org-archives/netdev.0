From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-01-11
Date: Sat, 11 Jan 2014 19:48:02 +0100
Message-ID: <52D191E2.8040703@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="VOruEJQKlALjjkOtPD1HGNabRNQuLMnTg"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VOruEJQKlALjjkOtPD1HGNabRNQuLMnTg
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of three patches for net-next/master.

Oleg Moroz added support for a new PCI card to the generic SJA1000 PCI
driver, Guenter Roeck's patch limits the flexcan driver to little
endian arm (and powerpc) and I fixed a sparse warning found by the
kbuild robot in the ti_hecc driver.

regards,
Marc
---

The following changes since commit 45593c2bd2d1e257d03d795f9c80e22e18f188=
f0:

  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge=
 (2014-01-10 17:59:34 -0500)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to ea79c1c18520c3a60a2fc8193e2fb58710812d4e:

  can: ti_hecc: fix endianness related sparse warning (2014-01-11 19:43:2=
6 +0100)

----------------------------------------------------------------
Guenter Roeck (1):
      can: Disable flexcan driver build for big endian CPU on ARM

Marc Kleine-Budde (1):
      can: ti_hecc: fix endianness related sparse warning

Oleg Moroz (1):
      can: sja1000: add support for Elcus CAN200PCI

 drivers/net/can/Kconfig           |  2 +-
 drivers/net/can/sja1000/plx_pci.c | 23 ++++++++++++++++++++++-
 drivers/net/can/ti_hecc.c         | 10 ++++------
 3 files changed, 27 insertions(+), 8 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--VOruEJQKlALjjkOtPD1HGNabRNQuLMnTg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLRkeIACgkQjTAFq1RaXHOs3wCggURqLHAU/9172Nwe+Y8D+ZYA
WvgAnj/tQaPwY0itp33Hv85dcshzkSBn
=N+hg
-----END PGP SIGNATURE-----

--VOruEJQKlALjjkOtPD1HGNabRNQuLMnTg--
