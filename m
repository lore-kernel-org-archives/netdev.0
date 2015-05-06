From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-05-06
Date: Wed, 6 May 2015 23:21:06 +0200
Message-ID: <554A85C2.1020700@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="HA6r4CFEX5fH6EVfwuWxtofVWl1takOdg"
Cc: davem@davemloft.net, kernel@pengutronix.de,
	linux-can@vger.kernel.org, David Jander <david@protonic.nl>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--HA6r4CFEX5fH6EVfwuWxtofVWl1takOdg
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of a seven patches for net-next/master.

Andreas Gr=C3=B6ger contributes two patches for the janz-ican3 driver. In=

the first patch, the documentation for already existing sysfs entries
is added, the second patch adds support for another module/firmware
variant. A patch by Shawn Landden makes the padding in the struct
can_frame explicit. The next 4 patches target the flexcan driver, the
first one is by David Jander adding some documentation, the reaming
three by me add more documentation and two small code cleanups.

regards,
Marc

---

The following changes since commit 239fb791d4ee194740e69fe9694f58ec404d16=
89:

  vxlan: Correctly set flow*i_mark and flow4i_proto in route lookups (201=
5-05-05 19:37:54 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.2-20150506

for you to fetch changes up to 10d089bd4b289cbe08d2565f34e030c8980682f4:

  can: flexcan: replace open coded "mailbox code" by proper define (2015-=
05-06 22:57:27 +0200)

----------------------------------------------------------------
linux-can-next-for-4.2-20150506

----------------------------------------------------------------
Andreas Gr=C3=B6ger (2):
      can: janz-ican3: add documentation for existing sysfs entries
      can: janz-ican3: add support for CAL/CANopen firmware

David Jander (1):
      can: flexcan: add MB/FIFO specific column to comment table of IP ve=
rsions

Marc Kleine-Budde (3):
      can: flexcan: add documentation about mailbox organization
      can: flexcan: rename struct flexcan_regs::crl2 -> ctrl2
      can: flexcan: replace open coded "mailbox code" by proper define

Shawn Landden (1):
      can.h: make padding given by gcc explicit

 .../ABI/testing/sysfs-bus-pci-drivers-janz-cmodio  |   8 ++
 .../ABI/testing/sysfs-class-net-janz-ican3         |  19 ++++
 Documentation/networking/can.txt                   |   3 +
 drivers/mfd/janz-cmodio.c                          |   4 +
 drivers/net/can/flexcan.c                          |  53 +++++----
 drivers/net/can/janz-ican3.c                       | 125 +++++++++++++++=
------
 include/uapi/linux/can.h                           |   6 +
 7 files changed, 159 insertions(+), 59 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-bus-pci-drivers-janz-=
cmodio
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-janz-ican3

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--HA6r4CFEX5fH6EVfwuWxtofVWl1takOdg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJVSoXGAAoJECte4hHFiupU9XEP/j2Z6mw1WB8JBUmpZlD+znNE
UYiBiZSRZCH7KTdna0P5DeffZ9VG19X84aCCQ9PXYbNaPVKOuUk7JrOE6z8s6heu
kyXYbZ0CfAGWcB2GJGzKfn5V1Pprtd2ocIvZ2XBres1Pn61CQ19SJxtQhi1w4eCY
Ie7v3oV/XxiFYvKU+c1VkEDi7ewwL8Bn83KXwXscTkCT2BY1I1Xc+R/tx+GWHy8h
ZkKoIS3P4d5TT9IHqhofjooZgCQSLTSEZkoMbitcjvQV+CI0214fvecTYIE0HWM1
wQsdS4oUOjyW/qD0EQDH/XrvCx+nPY+EL7S6UQ/SA3lMOLDrgcX6+HmTdoa26LDR
J2cjQHKNr+NCZYbWqjGbHijlJqMf/btxLZC7RUYL9HNLWWchbxj/3NkiFOj8AAC0
F01elK2Kg6Tp8hLuoDBqRCDKFvGHBDuD3hhXRPYHGv7ClpUD1G/iOX9UK489uGbM
mg9Q5EsX8jlOBtdIYaxFyD1Rb52Q7nbDqVKgmZPIE5PlTuHblC9wRHnaZ4FAFhE1
tDvnzcyfDfGRXmPUbpvpouIqu6KE6wnzNUyqQS0RsBYCNrOyOmESjr07ZoLsdvuC
tK9cd+gmNvFv4EhEdBptqG9T9RLf8HTNjOBMQyVSteSMj6TkaLFmTGc9qQbKO+rW
Ja3v3TqR1iLgAjSh6zU0
=Y+o8
-----END PGP SIGNATURE-----

--HA6r4CFEX5fH6EVfwuWxtofVWl1takOdg--
