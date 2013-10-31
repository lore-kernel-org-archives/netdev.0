From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can-next 2013-10-31
Date: Thu, 31 Oct 2013 21:06:28 +0100
Message-ID: <5272B844.9010100@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="HE4EAkvw6ea30wLjxR1wuJA9nlxUd7hik"
Cc: David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--HE4EAkvw6ea30wLjxR1wuJA9nlxUd7hik
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello David,

here's a pull request for net-next.

It includes a patch by Oliver Hartkopp et al. that adds documentation
for the broadcast manager to Documentation/networking/can.txt. Three
patches by me that clean up the netlink handling code in the CAN core.
And another patch that removes a not needed function from the ti_hecc
driver.

regards,
Marc

---

The following changes since commit ba4865027c11d7ac8e5a33e0624dd415caab20=
27:

  ipv6: remove the unnecessary statement in find_match() (2013-10-30 17:0=
6:51 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git for-davem

for you to fetch changes up to 26896fd98130cdda73b19c75849a0d25cb850cb8:

  can: ti_hecc: remove priv->can.do_get_state() callback (2013-10-31 20:5=
5:16 +0100)

----------------------------------------------------------------
Marc Kleine-Budde (4):
      can: dev: sort can_get_size() by IFLA_CAN_*
      can: dev: sort can_fill_info() by IFLA_CAN_*
      can: dev: sort can_changelink() by IFLA_CAN_*
      can: ti_hecc: remove priv->can.do_get_state() callback

Oliver Hartkopp (1):
      can: add broadcast manager documentation

 Documentation/networking/can.txt | 217 +++++++++++++++++++++++++++++++++=
++++++
 drivers/net/can/dev.c            |  67 ++++++------
 drivers/net/can/ti_hecc.c        |  10 --
 3 files changed, 249 insertions(+), 45 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--HE4EAkvw6ea30wLjxR1wuJA9nlxUd7hik
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlJyuEQACgkQjTAFq1RaXHMAfgCeP25mu2hv9Kl9E3r8nPfdYEYt
YT4An0JFH7Rj42rrO9NJ8glSFU9FKCJ9
=wiI2
-----END PGP SIGNATURE-----

--HE4EAkvw6ea30wLjxR1wuJA9nlxUd7hik--
