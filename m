From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:37:12 +0000
Message-ID: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="=-VtaGCwbFkCn7IgukV9i/"
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34507 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab3LEXhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:37:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-VtaGCwbFkCn7IgukV9i/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 018c5bba052b3a383d83cf0c756da0e7bc748397=
:

  net: Handle CHECKSUM_COMPLETE more adequately in pskb_trim_rcsum(). (2013=
-11-15 21:11:16 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git siocghwtst=
amp

for you to fetch changes up to a4bcc795e9cc84902b86edbfbb755ecb38d11f91:

  net_tstamp,doc: Add test program for SIOC{G,S}HWTSTAMP (2013-11-22 20:10:=
53 +0000)

1. Add the SIOCGHWTSTAMP ioctl and update the timestamping
documentation.
2. Implement SIOCGHWTSTAMP in most drivers that support SIOCSHWTSTAMP.
3. Add a test program to exercise SIOC{G,S}HWTSTAMP.

Ben.

----------------------------------------------------------------
Ben Hutchings (16):
      net_tstamp: Improve kernel-doc for struct hwtstamp_config
      net/compat: Fix minor information leak in siocdevprivate_ioctl()
      net/compat: Merge multiple implementations of ifreq::ifr_data convers=
ion
      net_tstamp: Add SIOCGHWTSTAMP ioctl to match SIOCSHWTSTAMP
      sfc: Implement the SIOCGHWTSTAMP ioctl
      bfin_mac: Implement the SIOCGHWTSTAMP ioctl
      tg3: Implement the SIOCGHWTSTAMP ioctl
      fec: Implement the SIOCGHWTSTAMP ioctl
      gianfar: Implement the SIOCGHWTSTAMP ioctl
      e1000e: Implement the SIOCGHWTSTAMP ioctl
      mlx4_en: Implement the SIOCGHWTSTAMP ioctl
      vxge: Implement the SIOCGHWTSTAMP ioctl
      ti_cpsw: Implement the SIOCGHWTSTAMP ioctl
      tile_net: Implement the SIOCGHWTSTAMP ioctl
      ixp4xx_eth: Implement the SIOCGHWTSTAMP ioctl
      net_tstamp,doc: Add test program for SIOC{G,S}HWTSTAMP

 Documentation/networking/timestamping.txt          |   9 +-
 Documentation/networking/timestamping/.gitignore   |   1 +
 Documentation/networking/timestamping/Makefile     |   5 +-
 .../networking/timestamping/hwtstamp_config.c      | 134 +++++++++++++++++=
++++
 drivers/net/ethernet/adi/bfin_mac.c                |  21 +++-
 drivers/net/ethernet/broadcom/tg3.c                |  71 ++++++++++-
 drivers/net/ethernet/freescale/fec.h               |   3 +-
 drivers/net/ethernet/freescale/fec_main.c          |   8 +-
 drivers/net/ethernet/freescale/fec_ptp.c           |  16 ++-
 drivers/net/ethernet/freescale/gianfar.c           |  22 +++-
 drivers/net/ethernet/intel/e1000e/netdev.c         |  14 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  14 ++-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |  27 +++--
 drivers/net/ethernet/sfc/efx.c                     |   4 +-
 drivers/net/ethernet/sfc/nic.h                     |   3 +-
 drivers/net/ethernet/sfc/ptp.c                     |  11 +-
 drivers/net/ethernet/ti/cpsw.c                     |  24 +++-
 drivers/net/ethernet/tile/tilegx.c                 |  22 +++-
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |  36 +++++-
 include/uapi/linux/net_tstamp.h                    |  16 +--
 include/uapi/linux/sockios.h                       |   3 +-
 net/core/dev_ioctl.c                               |   2 +
 net/socket.c                                       |  57 ++-------
 23 files changed, 423 insertions(+), 100 deletions(-)
 create mode 100644 Documentation/networking/timestamping/hwtstamp_config.c

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--=-VtaGCwbFkCn7IgukV9i/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQEcBAABCAAGBQJSoQ4oAAoJEGkILBsOca601AgH/iwA1Xz/Ng5DrDkNf9cWh4gf
5c3zRtzhb5TQFxTGvXjAVLhkEN8yhEUJJlCr58ckJIJW0BD9d4a4nkaCaZcNe9lc
4Dy0aPJ2ijJD9vOxNMg6Oz2VIOs9kD2t8xfA6M9EUksR11JcYfIDedxq8OSdQ1Do
y5i35XA+7iuVLbSuHT6QxbHRUJ9caSU7oF7ORReoY7Qla5aSsWj3hJTe3um7jJAr
BVXJahmbZhwQ5/4037uAI+e3BDUzUoxMCoIndMMgSVjlmZl5Sad5r+0QNdWj8Y8k
QkdwrrR3YYk5ElEtng6d9kepn2qdOnm7N2HFoVSy3Kl3cXSM5ZIludABmIlaq5Q=
=S7Gc
-----END PGP SIGNATURE-----

--=-VtaGCwbFkCn7IgukV9i/--
