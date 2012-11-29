From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2012-11-29
Date: Thu, 29 Nov 2012 14:50:13 +0100
Message-ID: <50B76815.8010907@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7F8DD1AC1339AA301ED25436"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7F8DD1AC1339AA301ED25436
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

this pull request is for net-next/master. There is a patch by Alexander
Stein fixing a reference counter problem which can make driver
unloading impossible (stable Cc'ed). And several patches by me which
remove an obsolete mechanism from several drivers, which is already
handled at the infrastructure level.

regards,
Marc

---

The following changes since commit 3177bf6f922f62743133abbcbbbb5545f4133b=
2d:

  net: ethernet: cpsw: fix build warnings for CPSW when CPTS not selected=
 (2012-11-28 17:51:16 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 823d7a1f761d6404babaab04cc8b1724186cf2c8:

  can: pcan_usb_core: remove obsolete variable open_time (2012-11-29 14:3=
4:06 +0100)

----------------------------------------------------------------
Alexander Stein (1):
      can: Do not call dev_put if restart timer is running upon close

Marc Kleine-Budde (5):
      can: mscan: remove obsolete variable open_time
      can: sja1000: remove obsolete variable open_time
      can: ems_usb: remove obsolete variable open_time
      can: esd_usb2: remove obsolete variable open_time
      can: pcan_usb_core: remove obsolete variable open_time

 drivers/net/can/dev.c                        |    3 +--
 drivers/net/can/mscan/mscan.c                |    8 --------
 drivers/net/can/mscan/mscan.h                |    1 -
 drivers/net/can/sja1000/sja1000.c            |    8 --------
 drivers/net/can/sja1000/sja1000.h            |    1 -
 drivers/net/can/usb/ems_usb.c                |    7 -------
 drivers/net/can/usb/esd_usb2.c               |   10 ----------
 drivers/net/can/usb/peak_usb/pcan_usb_core.c |    5 -----
 drivers/net/can/usb/peak_usb/pcan_usb_core.h |    1 -
 9 files changed, 1 insertion(+), 43 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig7F8DD1AC1339AA301ED25436
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlC3aBsACgkQjTAFq1RaXHMm4ACfTvN3brwMWLodooo56qDVwoB7
XK0An0Hwfe29g9o3SJoiHRyb1tl+fnRc
=VgFz
-----END PGP SIGNATURE-----

--------------enig7F8DD1AC1339AA301ED25436--
