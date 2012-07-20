From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2012-07-20
Date: Fri, 20 Jul 2012 18:27:50 +0200
Message-ID: <50098706.2080509@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig602B74502FF92E8C8FCDC34D"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig602B74502FF92E8C8FCDC34D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

the fifth pull request for upcoming v3.6 net-next cleans up and
improves the janz-ican3 driver (6 patches by Ira W. Snyder, one by me).
A patch by Steffen Trumtrar adds imx53 support to the flexcan driver.
And another patch by me, which marks the bit timing constant in the CAN
drivers as "const".

regards, Marc

---

The following changes since commit 769162e38b91e1d300752e666260fa6c7b203f=
bc:

  Merge branch 'net' of git://git.kernel.org/pub/scm/linux/kernel/git/cme=
tcalf/linux-tile (2012-07-19 13:39:27 -0700)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 3b5c6b9e49f78f07ebcd34b38c1185e57a0fd9eb:

  can: janz-ican3: add support for one shot mode (2012-07-20 17:49:05 +02=
00)

----------------------------------------------------------------
Ira W. Snyder (6):
      can: janz-ican3: remove dead code
      can: janz-ican3: drop invalid skbs
      can: janz-ican3: fix error and byte counters
      can: janz-ican3: fix support for CAN_RAW_RECV_OWN_MSGS
      can: janz-ican3: avoid firmware lockup caused by infinite bus error=
 quota
      can: janz-ican3: add support for one shot mode

Marc Kleine-Budde (2):
      can: mark bittiming_const pointer in struct can_priv as const
      can: janz-ican3: cleanup of ican3_to_can_frame and can_frame_to_ica=
n3

Steffen Trumtrar (1):
      can: flexcan: add 2nd clock to support imx53 and newer

 drivers/net/can/at91_can.c                   |    2 +-
 drivers/net/can/bfin_can.c                   |    2 +-
 drivers/net/can/c_can/c_can.c                |    2 +-
 drivers/net/can/cc770/cc770.c                |    2 +-
 drivers/net/can/flexcan.c                    |   47 +++--
 drivers/net/can/janz-ican3.c                 |  241 ++++++++++++++++++++=
------
 drivers/net/can/mcp251x.c                    |    2 +-
 drivers/net/can/mscan/mscan.c                |    2 +-
 drivers/net/can/pch_can.c                    |    2 +-
 drivers/net/can/sja1000/sja1000.c            |    2 +-
 drivers/net/can/ti_hecc.c                    |    2 +-
 drivers/net/can/usb/ems_usb.c                |    2 +-
 drivers/net/can/usb/esd_usb2.c               |    2 +-
 drivers/net/can/usb/peak_usb/pcan_usb_core.h |    2 +-
 include/linux/can/dev.h                      |    2 +-
 15 files changed, 226 insertions(+), 88 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig602B74502FF92E8C8FCDC34D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAlAJhwoACgkQjTAFq1RaXHN0aACeLgRPKFVis94vJ9ve0m9BUO2F
uX4AoJeHrOcP2t0apf1bUKs4zjy1Qot8
=ZX6x
-----END PGP SIGNATURE-----

--------------enig602B74502FF92E8C8FCDC34D--
