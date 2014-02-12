From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-02-12
Date: Wed, 12 Feb 2014 11:15:19 +0100
Message-ID: <52FB49B7.8090403@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="q0iGRAOVpkmptNKoFIt9a1iw00rUIOFxG"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--q0iGRAOVpkmptNKoFIt9a1iw00rUIOFxG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of eight patches for net-next/master.

Florian Vaussard contributed a series that merged the sja1000 of_platform=

into the platform driver. The of_platform driver is finally removed.
Stephane Grosjean supplied a patch to allocate CANFD skbs. In a patch
by Uwe Kleine-K=C3=B6nig another missing copyright information was added =
to
a userspace header. And a patch by Yoann DI RUZZA that adds listen only
mode to the at91_can driver.

regards,
Marc
---
The following changes since commit 77d143de75812596a58d126606f42d1214e09d=
de:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/rw/uml (2014-01-26 11:06:16 -0800)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-fo=
r-3.15-20140212

for you to fetch changes up to 17a50ee4bd47bdba94546e0526fc9ce93dc77d5e:

  can: at91_can: add listen only mode (2014-02-11 09:55:44 +0100)

----------------------------------------------------------------
linux-can-next-for-3.15-20140212

----------------------------------------------------------------
Florian Vaussard (5):
      can: sja1000: convert printk to use netdev API
      can: sja1000: platform: use devm_* APIs
      can: sja1000: fuse of_platform into platform
      Documentation: devicetree: sja1000: add reg-io-width binding
      can: sja1000: of: add reg-io-width property for 8, 16 and 32-bit re=
gister access

Stephane Grosjean (1):
      can: add ability to allocate CANFD frame in skb data

Uwe Kleine-K=C3=B6nig (1):
      can: add explicit copyrights to can userspace header

Yoann DI RUZZA (1):
      can: at91_can: add listen only mode

 .../devicetree/bindings/net/can/sja1000.txt        |   4 +
 drivers/net/can/at91_can.c                         |   9 +-
 drivers/net/can/dev.c                              |  24 +++
 drivers/net/can/sja1000/Kconfig                    |  13 +-
 drivers/net/can/sja1000/Makefile                   |   1 -
 drivers/net/can/sja1000/sja1000.c                  |   3 +-
 drivers/net/can/sja1000/sja1000_of_platform.c      | 220 ---------------=
------
 drivers/net/can/sja1000/sja1000_platform.c         | 194 ++++++++++++---=
---
 include/linux/can/dev.h                            |   2 +
 include/uapi/linux/can.h                           |  32 +++
 10 files changed, 206 insertions(+), 296 deletions(-)
 delete mode 100644 drivers/net/can/sja1000/sja1000_of_platform.c

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |




--q0iGRAOVpkmptNKoFIt9a1iw00rUIOFxG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlL7SbcACgkQjTAFq1RaXHN6AQCcCfN3lWRHubRS4hI1u/Gy7klG
xk8Anip6MnLW1sguYXcXqMRMbOyYzp97
=eRkQ
-----END PGP SIGNATURE-----

--q0iGRAOVpkmptNKoFIt9a1iw00rUIOFxG--
