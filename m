From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2015-09-17
Date: Mon, 21 Sep 2015 09:20:21 +0200
Message-ID: <55FFAFB5.7040707@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Jpn42Lw0vuvLXqvr7BtuvsuCvKV9hmJCQ"
Cc: David Miller <davem@davemloft.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Jpn42Lw0vuvLXqvr7BtuvsuCvKV9hmJCQ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of 8 patches for net-next/master.

All 8 patches are by me and cleanup the flexcan driver.

Marc

---

The following changes since commit a1ef48e1e8843e2f6be631b8cf1c21b24579b9=
d6:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/=
jkirsher/next-queue (2015-09-20 22:26:58 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git ta=
gs/linux-can-next-for-4.4-20150921

for you to fetch changes up to 6fa7da249269a6146ce456c43098901c81c8afdf:

  can: flexcan: enable interrupts atomically at the end of flexcan_chip_s=
tart() (2015-09-21 08:38:23 +0200)

----------------------------------------------------------------
linux-can-next-for-4.4-20150921

----------------------------------------------------------------
Marc Kleine-Budde (8):
      can: flexcan: cleanup coding style and fix typos
      can: headers: make header files self contained
      can: flexcan: remove unused header files
      can: flexcan: flexcan_chip_start(): cleanup writing of reg_mcr
      can: flexcan: rename feature into quirks
      can: flexcan: use pointer to struct regs instead of void pointer fo=
r mmio address space
      can: flexcan: give member of flexcan_priv holding mailboxes a sensi=
ble name
      can: flexcan: enable interrupts atomically at the end of flexcan_ch=
ip_start()

 drivers/net/can/flexcan.c | 197 ++++++++++++++++++++++------------------=
------
 include/linux/can/dev.h   |   3 +-
 include/linux/can/led.h   |   1 +
 3 files changed, 95 insertions(+), 106 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Jpn42Lw0vuvLXqvr7BtuvsuCvKV9hmJCQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJV/6+4AAoJEP5prqPJtc/HK1cIAI9qPodkNyah73H2FxtABoJE
hAtUvocRLX+CWVWYaUJ8ZQrEQ9ewVVtCiieXa4rGchTfF/2KLGSW7ObjrURVLObU
lRv9V7u0zY9OLPK0zpB2FXPOX6VOIYc5IPWiea0k9nDJKvoJowGh5FRQiZfSOhPs
aVxWuY7PwovLDWQWKvZrzxSVaSAmniTper/RD03+2BjsZlXM0yNSx7WisIcjCgFT
enMhcR6ToPUlyRXqx8OflSsjG+87Vx4nWUN9Ksno7FDpw/G762X7qepmAcV53mXN
pyHLrfLGh/BoB8GiA82vm/UhfP1w+zhaEW4DSOK3tg+zmWg8mKUO5FyH8Hhnvc8=
=W9Nb
-----END PGP SIGNATURE-----

--Jpn42Lw0vuvLXqvr7BtuvsuCvKV9hmJCQ--
