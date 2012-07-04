From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2012-07-04
Date: Wed, 04 Jul 2012 17:00:49 +0200
Message-ID: <4FF45AA1.2040907@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig20E4119E0561333F34AD204C"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig20E4119E0561333F34AD204C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

our third pull request for upcoming v3.6 net-next. First Oliver and me
fix some sparse warnings, then 3 patches by Hui Wang and Shawn Guo
which improve flexcan support and finally the patch by Rostislav Lisovy
that adds CAN frame classifier.

regards,
Marc

---

The following changes since commit e87183c2b5ab1f55ebad2f260a7eb4d31549ce=
25:

  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge=
 (2012-07-01 17:56:33 -0700)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to f057bbb6f9ed0fb61ea11105c9ef0ed5ac1a354d:

  net: em_canid: Ematch rule to match CAN frames according to their ident=
ifiers (2012-07-04 13:07:05 +0200)

----------------------------------------------------------------
Hui Wang (2):
      can: flexcan: use of_property_read_u32 to get DT entry value
      can: flexcan: add hardware controller version support

Marc Kleine-Budde (2):
      can: cc770: fix sparse warning for cc770_interrupt
      can: dev: fix sparse warning for can_restart

Oliver Hartkopp (1):
      can: fix sparse warning in af_can.c

Rostislav Lisovy (1):
      net: em_canid: Ematch rule to match CAN frames according to their i=
dentifiers

Shawn Guo (1):
      net: flexcan: clock-frequency is optional for device tree probe

 .../devicetree/bindings/net/can/fsl-flexcan.txt    |    3 +
 drivers/net/can/cc770/cc770.c                      |    2 +-
 drivers/net/can/dev.c                              |    2 +-
 drivers/net/can/flexcan.c                          |   71 ++++--
 include/linux/can.h                                |    3 +
 include/linux/pkt_cls.h                            |    5 +-
 net/can/af_can.h                                   |    3 +
 net/can/proc.c                                     |    3 -
 net/sched/Kconfig                                  |   10 +
 net/sched/Makefile                                 |    1 +
 net/sched/em_canid.c                               |  240 ++++++++++++++=
++++++
 11 files changed, 320 insertions(+), 23 deletions(-)
 create mode 100644 net/sched/em_canid.c

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig20E4119E0561333F34AD204C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/0WqUACgkQjTAFq1RaXHNxagCfToJGZP9LCeSUofneRwxe3JtM
ELoAniEtfpOVyJoGM89CYjxYNoaZggoj
=xTaG
-----END PGP SIGNATURE-----

--------------enig20E4119E0561333F34AD204C--
