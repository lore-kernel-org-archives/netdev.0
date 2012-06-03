From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2012-06-04
Date: Mon, 04 Jun 2012 00:52:27 +0200
Message-ID: <4FCBEAAB.90708@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA252A5FC2C352B7A70302079"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA252A5FC2C352B7A70302079
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello David,

here are the first patches for net-next, they add power management
support for the flexcan driver and clarify the documentation with
respect to error messages.

regards, Marc

---

The following changes since commit 31a67102f4762df5544bc2dfb34a931233d2a5=
b2:

  Fix blocking allocations called very early during bootup (2012-05-21 12=
:52:42 -0700)

are available in the git repository at:
  git@gitorious.org:linux-can/linux-can-next.git master

Eric B=E9nard (1):
      can: flexcan: add PM support

Oliver Hartkopp (1):
      can: update documentation wording error frames -> error messages

 Documentation/networking/can.txt |   32 ++++++++++++++++----------------=

 drivers/net/can/flexcan.c        |   38 ++++++++++++++++++++++++++++++++=
++++++
 include/linux/can.h              |    8 ++++----
 include/linux/can/error.h        |    4 ++--
 net/can/af_can.c                 |   10 +++++-----
 5 files changed, 65 insertions(+), 27 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigA252A5FC2C352B7A70302079
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk/L6rAACgkQjTAFq1RaXHMsgwCcCc4TqGUApBL/SS+fSrZhjm3H
4psAniwHB34nl/XTHyUZbgEU73mQpslE
=hp53
-----END PGP SIGNATURE-----

--------------enigA252A5FC2C352B7A70302079--
