From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: updates to the mscan-driver in net-next
Date: Tue, 17 Nov 2009 14:07:44 +0100
Message-ID: <20091117130744.GC15339@pengutronix.de>
References: <1258412274-14686-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JgQwtEuHJzHdouWu"
Cc: socketcan-core@lists.berlios.de, linuxppc-dev@ozlabs.org,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56365 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbZKQNHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 08:07:42 -0500
Content-Disposition: inline
In-Reply-To: <1258412274-14686-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--JgQwtEuHJzHdouWu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> I will also update my branch on pengutronix.de tomorrow,

Done.

=3D=3D=3D

The following changes since commit a0a9020c1725cd5c9a13a7aab65831f3c85ea9ca:
  Wolfram Sang (1):
        net/can/mscan: final checkpatch cleanups

are available in the git repository at:

  git://git.pengutronix.de/git/wsa/linux-2.6.git net-next-52xx-can

Wolfram Sang (11):
      net/can/mscan: move defines into .h file
      net/can/mscan: trivial fixes
      net/can/mscan: drop support for CAN_MODE_{SLEEP|STOP}
      net/can/mscan: use {clr|set}bits8 macros
      net/can/mscan: fix function annotations
      net/can/mscan: drop assignment in while-construct
      net/can/mpc52xx_can: refactor clock-get routine
      net/can/mpc52xx_can: improve properties and their description
      net/can/mscan: replace hardcoded values with defines
      net/can/mscan: add error path to mscan_open()
      net/can/mscan: improve build

 Documentation/powerpc/dts-bindings/fsl/mpc5200.txt |    9 +-
 drivers/net/can/Kconfig                            |   19 +---
 drivers/net/can/mscan/Kconfig                      |   23 ++++
 drivers/net/can/mscan/Makefile                     |    4 +-
 .../net/can/mscan/{mpc52xx_can.c =3D> mpc5xxx_can.c} |   64 ++++-------
 drivers/net/can/mscan/mscan.c                      |  121 +++++++---------=
---
 drivers/net/can/mscan/mscan.h                      |   36 ++++++-
 7 files changed, 133 insertions(+), 143 deletions(-)
 create mode 100644 drivers/net/can/mscan/Kconfig
 rename drivers/net/can/mscan/{mpc52xx_can.c =3D> mpc5xxx_can.c} (90%)

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--JgQwtEuHJzHdouWu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksCoCAACgkQD27XaX1/VRunpgCfcFxc4RffYl9oWppE2Ug4tyL9
ICYAn3/8HxEZU2NxZ0JNDJ3327+0s7IQ
=wVrr
-----END PGP SIGNATURE-----

--JgQwtEuHJzHdouWu--
