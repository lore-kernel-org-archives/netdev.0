From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-28-01
Date: Wed, 28 Jan 2015 14:58:42 +0100
Message-ID: <54C8EB12.9030100@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="dd98LWTGFEupCSnvCK6qMXdo5fCkx0jVf"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--dd98LWTGFEupCSnvCK6qMXdo5fCkx0jVf
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 12 patches for net-next/master.

There are 3 patches by Ahmed S. Darwish, which update the kvaser_usb
driver and add support for the USBcan-II based adapters. St=C3=A9phane
Grosjean contributes 7 patches for the peak_usb driver, which add
support for the CANFD USB adapters. I contribute 2 patches which clean
up the peak_usb driver structure a bit.

Marc

---

The following changes since commit ff660f75be36e6db75d45dc742a4a468c5a9c2=
0d:

  Merge branch 'stmmac-pci' (2015-01-27 21:08:13 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-3.20-20150128

for you to fetch changes up to 0a25e1f4f18566b750ebd3ae995af64e23111e63:

  can: peak_usb: add support for PEAK new CANFD USB adapters (2015-01-28 =
14:47:06 +0100)

----------------------------------------------------------------
linux-can-next-for-3.20-20150128

----------------------------------------------------------------
Ahmed S. Darwish (3):
      can: kvaser_usb: Update interface state before exiting on OOM
      can: kvaser_usb: Consolidate and unify state change handling
      can: kvaser_usb: Add support for the USBcan-II family

Marc Kleine-Budde (2):
      can: peak_usb: use ARRAY_SIZE instead of NULL termination for peak_=
usb_adapters_list
      can: peak_usb: constify struct peak_usb_adapter

Stephane Grosjean (7):
      can: peak_usb: export ctrlmode_supported to adapter specific defini=
tion
      can: peak_usb: add adapter BEC callback definition
      can: peak_usb: upgrade core to data bittiming specs
      can: peak_usb: upgrade core to new struct canfd_frame
      can: peak_usb: export pcan_usb_pro functions
      can: peak_usb: add peak_usb_netif_rx() new function
      can: peak_usb: add support for PEAK new CANFD USB adapters

 drivers/net/can/usb/Kconfig                  |   22 +-
 drivers/net/can/usb/kvaser_usb.c             |  722 ++++++++++++-----
 drivers/net/can/usb/peak_usb/Makefile        |    2 +-
 drivers/net/can/usb/peak_usb/pcan_ucan.h     |  222 ++++++
 drivers/net/can/usb/peak_usb/pcan_usb.c      |    3 +-
 drivers/net/can/usb/peak_usb/pcan_usb_core.c |   83 +-
 drivers/net/can/usb/peak_usb/pcan_usb_core.h |   26 +-
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c   | 1095 ++++++++++++++++++++=
++++++
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c  |   19 +-
 drivers/net/can/usb/peak_usb/pcan_usb_pro.h  |   13 +
 10 files changed, 1981 insertions(+), 226 deletions(-)
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_ucan.h
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb_fd.c

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
























--dd98LWTGFEupCSnvCK6qMXdo5fCkx0jVf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJUyOsVAAoJECte4hHFiupUzToP/05IGBtduHOPM+JEyEmGgbf/
QseZmQJ1LEA0IYGyXB+e+sQdEs9/43KVIwXoXaVZz8OI37MtMmOuv4hYqFeBDqLV
rJlpKWXcwKLFzVBLkqCP/+gPDHTV9eODM6zoiolqWRt7j5SPDqhK0UeTEq3yjZuP
bug/tLK6kfENVzF6EiTPBp/rRNgadRPB7TM3HvPuTCVqkWtcY6MjeDc+HFrEgjix
Rt9IpWTp5+82Ovt/oAMfOUOdToA8WHpdUXzHil6pZoS3ScXCSfMZXGSEPKro3c+N
UGC2pba+OhoDMPLAlR0yx/J/2/xoh4rSHm+e1g4CxW7RNqr7dcQja64oxmQDxle1
P/DewTrugbIIluAXkHpywJd/eZs3u+5VqD8TIBleFdV+AkWu3LaGxZntqTPoylRj
NLxkvANDdjTTf+BtZ9SZbzfnXyYkVntbZ477mYAEanqKu0gIj+z2jIg495SU0D2m
/2J/w0bnToZU78RuuR0Iahuq77Xr0qodTpcksVkR1hz8FiXMWnkb8ZhFl/IkA6t2
b0f6sAJuFIh6s0k6fe8BY+zKrAhA5UyookYh/iNFd1KkHbZRV2h2G1voqR3fPJqn
xG+C8ZrzXagvwCFbjZw6gsDFdARKUsAo10EOH8cfRyQP5HDfFc/bt8Wfw/h44pl7
EV0ibOtEHJHNYBctsZxC
=581V
-----END PGP SIGNATURE-----

--dd98LWTGFEupCSnvCK6qMXdo5fCkx0jVf--
