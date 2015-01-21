From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-21-01
Date: Wed, 21 Jan 2015 23:58:19 +0100
Message-ID: <54C02F0B.7030509@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="tfTP5rqOXrI9nHioJ6GrBvdisXneJ5Wcj"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--tfTP5rqOXrI9nHioJ6GrBvdisXneJ5Wcj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 4 patches for net-next/master.

Andri Yngvason contributes one patch to further consolidate the CAN
state change handling. The next patch is by kbuild test robot/Fengguang
Wu which fixes a coccinelle warning in the CAN infrastructure. The two
last patches are by me, they remove a unused variable from the flexcan
and at91_can driver.

Marc

---

The following changes since commit 0c49087462e8587c12ecfeaf1dd46fdc0ddc45=
32:

  Merge tag 'mac80211-next-for-davem-2015-01-19' of git://git.kernel.org/=
pub/scm/linux/kernel/git/jberg/mac80211-next (2015-01-19 16:22:19 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-3.20-20150121

for you to fetch changes up to ef186f25fdf00d92c6bd5d3301fc0ee44f17ca33:

  can: at91_can: remove unused variable (2015-01-21 22:47:44 +0100)

----------------------------------------------------------------
linux-can-next-for-3.20-20150121

----------------------------------------------------------------
Andri Yngvason (1):
      can: move can_stats.bus_off++ from can_bus_off into can_change_stat=
e

Marc Kleine-Budde (2):
      can: flexcan: remove unused variable
      can: at91_can: remove unused variable

kbuild test robot (1):
      can: dev: fix semicolon.cocci warnings

 drivers/net/can/at91_can.c                  | 2 --
 drivers/net/can/bfin_can.c                  | 1 +
 drivers/net/can/c_can/c_can.c               | 2 +-
 drivers/net/can/cc770/cc770.c               | 1 +
 drivers/net/can/dev.c                       | 5 +++--
 drivers/net/can/flexcan.c                   | 2 --
 drivers/net/can/janz-ican3.c                | 1 +
 drivers/net/can/m_can/m_can.c               | 1 +
 drivers/net/can/pch_can.c                   | 1 +
 drivers/net/can/rcar_can.c                  | 1 +
 drivers/net/can/softing/softing_main.c      | 1 +
 drivers/net/can/spi/mcp251x.c               | 1 +
 drivers/net/can/ti_hecc.c                   | 1 +
 drivers/net/can/usb/ems_usb.c               | 1 +
 drivers/net/can/usb/esd_usb2.c              | 1 +
 drivers/net/can/usb/peak_usb/pcan_usb.c     | 1 +
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c | 1 +
 drivers/net/can/usb/usb_8dev.c              | 1 +
 18 files changed, 18 insertions(+), 7 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |






















--tfTP5rqOXrI9nHioJ6GrBvdisXneJ5Wcj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUwC8PAAoJECte4hHFiupU5EcP/R8JqDHCRUqapOi93VHFqnqO
1k7zK4Ie7OqpVrc0N4YRdzChtYv5dXp+5Z9uZgcT4MTrdgeQvjs9UQZ8xsxRDaLF
JPS4TV2MLHxzI6NRxyG/TwtN25EE+rt2HmabAW0pS3ykd8VZRjjW5MtPE30q2MF9
yXgoXIxTMgXYjKja5yTAUha6vLVtdLXW1mkMl/OPz5Qv30iW/aAYuA6pBCIE9XEP
gnyHXAhKnU0V/wFupOCTO186TwOmcNi08hahXOZ/hRK3MIr7hdhIr1ZSr0hGjdqv
Oni8a/uIlXCRpBd0Nh34soahlfv/umUarWNIkMoD37L0c7yRLfEJ0MS2jV3X4Nne
TzmWHkdU+z02jcPS5GsQnI/Gv67tSvMuPFrNd1DeJ6DX90eJBeWnb1t5AifOeHP6
X5IhvBj0mWj0Amb+5pmrKGAncpOD/PqumE4uhou2Pu3mV9K6sVrLRYQ8RHruIrm5
uJM8K6CIUZcUjDM3CRbRRipV37ZhnXcfwWrdgcV9ahjueL9gOfh2jsl1UHyXO/mI
PyRJJIubN0FQbhKZL+B6G0PrtmTq777djalO6RpMf+ejr6M+YYDy/xO8VWEZO72G
cRkqLT0MtjLhFhu1gtOFvOUSdOojQqMFhvEtZJZzDleFAGydZErC2xK9YbcR3/0z
79tfsRRQT9aeoyuXvZJV
=v9uA
-----END PGP SIGNATURE-----

--tfTP5rqOXrI9nHioJ6GrBvdisXneJ5Wcj--
