From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-05-06
Date: Tue, 9 Jun 2015 09:45:29 +0200
Message-ID: <55769999.5060902@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="MOr5r8ePN97ih4AaljeaR8flL9eKbD5nC"
Cc: David Jander <david@protonic.nl>, davem@davemloft.net,
	kernel@pengutronix.de, linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MOr5r8ePN97ih4AaljeaR8flL9eKbD5nC
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of a two patches for net-next.

The first patch is by Tomas Krcka, he fixes the (currently unused)
register address for acceptance filters. Oliver Hartkopp contributes a
patch for the cangw, where an optional UID is added to reference
routing jobs.

regards,
Marc

---

The following changes since commit 941742f49762ba4c908510f036b09a46c1b145=
13:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-06-=
08 20:06:56 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.2-20150609

for you to fetch changes up to dd895d7f21b244e7fd4c7477697e274de7e44ecb:

  can: cangw: introduce optional uid to reference created routing jobs (2=
015-06-09 09:39:49 +0200)

----------------------------------------------------------------
linux-can-next-for-4.2-20150609

----------------------------------------------------------------
Oliver Hartkopp (1):
      can: cangw: introduce optional uid to reference created routing job=
s

Tomas Krcka (1):
      can: mcp251x: use correct register address for acceptance filters

 drivers/net/can/spi/mcp251x.c |  9 +++---
 include/uapi/linux/can/gw.h   |  5 ++++
 net/can/gw.c                  | 68 +++++++++++++++++++++++++++++++++++--=
------
 3 files changed, 66 insertions(+), 16 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--MOr5r8ePN97ih4AaljeaR8flL9eKbD5nC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJVdpmZAAoJEP5prqPJtc/H8PkH/0k7lwGWmzVvdHUOJOiaoYkr
9UlsYpjS0Dbk/yjfcnoxSzm+/I5pK/ED1q9bztMRVXOw8o0hs2rh9Re5822vcxe/
fu8PYw2jUdJrXmh07y7Whyd8USoYnp2xfW56WtyUZdVbfUmrP9WTkI1XLdcTVdBs
VAu66o/+QxILq3i0+FxtrD3PGgMV+87JVfThdQ6TKJziPcL0OYgAH6yVmkRUjmgd
x/Y8EXp+P8pbUk5cQ58Y6YXzTXRPWkPJz1c2XHpGUEqAtILo0neJAIVyH23BcVC8
84Ch28U814jldQyQTEDbqKlG5A/bkuwSCTa9srb4HEAauKFvhxXiYZb8b1PPzRE=
=n2cp
-----END PGP SIGNATURE-----

--MOr5r8ePN97ih4AaljeaR8flL9eKbD5nC--
