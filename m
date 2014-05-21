From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2014-05-19
Date: Wed, 21 May 2014 13:09:55 +0200
Message-ID: <537C8983.6050204@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="mGIvfO53vEvchqKBIj0bvxFEjBlHaaGrn"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mGIvfO53vEvchqKBIj0bvxFEjBlHaaGrn
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

this is a pull request of a single patch for net-next/master. It fixes a
use after free(), which slipped into to gs_usb driver.

Marc

---
The following changes since commit 2a7ede540785cac631a7e7334701a25e949853=
a8:

  Merge tag 'linux-can-next-for-3.16-20140519' of
git://gitorious.org/linux-can/linux-can-next (2014-05-21 02:00:27 -0400)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can-next.git
tags/linux-can-next-for-3.16-20140521

for you to fetch changes up to cf68f517c5c5041e3f3de502dccb008ec21f7262:

  can: gs_usb: gs_destroy_candev(): fix use after free (2014-05-21
13:04:20 +0200)

----------------------------------------------------------------
linux-can-next-for-3.16-20140521

----------------------------------------------------------------
Marc Kleine-Budde (1):
      can: gs_usb: gs_destroy_candev(): fix use after free

 drivers/net/can/usb/gs_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--mGIvfO53vEvchqKBIj0bvxFEjBlHaaGrn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlN8iYMACgkQjTAFq1RaXHOfvACfR7wOkVR+8J62rj2YuxL7kr4S
RqIAn0o6LivlRgD3IGf0RbXgLxqfotCz
=7Gnk
-----END PGP SIGNATURE-----

--mGIvfO53vEvchqKBIj0bvxFEjBlHaaGrn--
