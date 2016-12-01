From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2016-12-01
Date: Thu, 1 Dec 2016 21:21:44 +0100
Message-ID: <de63a1d8-2822-2d98-973c-c1b2f8c493cf@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="B4KBEbLD6O0eQjcoKqrecwcbLnhx8xdXV"
Cc: David Miller <davem@davemloft.net>,
        "kernel@pengutronix.de" <kernel@pengutronix.de>,
        "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:39501 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754141AbcLAUhE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:37:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--B4KBEbLD6O0eQjcoKqrecwcbLnhx8xdXV
Content-Type: multipart/mixed; boundary="PsKBTs1ChGK6iG974jPSm4mvAJSVeAEfJ";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>,
 "kernel@pengutronix.de" <kernel@pengutronix.de>,
 "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Message-ID: <de63a1d8-2822-2d98-973c-c1b2f8c493cf@pengutronix.de>
Subject: pull-request: can-next 2016-12-01

--PsKBTs1ChGK6iG974jPSm4mvAJSVeAEfJ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 4 patches for net-next/master.

There are two patches by Chris Paterson for the rcar_can and rcar_canfd
device tree binding documentation. And a patch by Geert Uytterhoeven
that corrects the order of interrupt specifiers.

The fourth patch by Colin Ian King fixes a spelling error in the
kvaser_usb driver.


regards,
Marc

---
The following changes since commit 8f679ed88f8860206edddff725e2749b4cdbb0=
e8:

  driver: ipvlan: Remove useless member mtu_adj of struct ipvl_dev (2016-=
11-30 15:01:32 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.10-20161201

for you to fetch changes up to 0d8f8efd32bace9f222fcc92d4a3132d877e5df6:

  net: can: usb: kvaser_usb: fix spelling mistake of "outstanding" (2016-=
12-01 14:27:02 +0100)

----------------------------------------------------------------
linux-can-next-for-4.10-20161201

----------------------------------------------------------------
Chris Paterson (2):
      can: rcar_can: Add r8a7796 support
      can: rcar_canfd: Add r8a7796 support

Colin Ian King (1):
      net: can: usb: kvaser_usb: fix spelling mistake of "outstanding"

Geert Uytterhoeven (1):
      can: rcar_canfd: Correct order of interrupt specifiers

 Documentation/devicetree/bindings/net/can/rcar_can.txt   | 12 +++++++---=
--
 Documentation/devicetree/bindings/net/can/rcar_canfd.txt | 14 ++++++++--=
----
 drivers/net/can/usb/kvaser_usb.c                         |  4 ++--
 3 files changed, 17 insertions(+), 13 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--PsKBTs1ChGK6iG974jPSm4mvAJSVeAEfJ--

--B4KBEbLD6O0eQjcoKqrecwcbLnhx8xdXV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlhAhloACgkQPTuqJayp
JWrOgggAvEaKSAx2xSJUrFMmWg3XU5XkNLADF3orH0tDy9J0EQTDWhwhSZfvp5mC
iMWWDxqvhZZUhumpSwdNyCm2RyK7yuM0oR0I05xvCcNv5zT4d0m3xTvLQNNncRfX
QRqduVJ7tyI0r+K3aemUVQ8+9WUOU8bEuj0FbHiHKP23MPMs1+BMfckziAshlB3F
9tZn2o00L9wt5Eu5hfA2/JDZNNNFHkuSh+UDPrFzhJQBG8vsfVQq/UDFq3GIoUQH
uWOj64f9oQ5a740lUaOHTHAfgnImKWiwSSYVzPAt5BSA/1fSB2g77+yxObQnERXX
tguN4otzQOoHpqh1X3liw1WY222BoQ==
=WVSN
-----END PGP SIGNATURE-----

--B4KBEbLD6O0eQjcoKqrecwcbLnhx8xdXV--
