From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH stable 3.9+] can: add destructor for self generated skbs
Date: Thu, 30 Jan 2014 10:24:08 +0100
Message-ID: <52EA1A38.1000904@pengutronix.de>
References: <52EA1740.2010108@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="WA6A5mqktXmbQBJ6IkS0PDHfQt7VhEOHV"
Cc: Andre Naujoks <nautsch2@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52EA1740.2010108@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WA6A5mqktXmbQBJ6IkS0PDHfQt7VhEOHV
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/30/2014 10:11 AM, Oliver Hartkopp wrote:
> Self generated skbuffs in net/can/bcm.c are setting a skb->sk reference=
 but
> no explicit destructor which is enforced since Linux 3.11 with commit
> 376c7311bdb6 (net: add a temporary sanity check in skb_orphan()).
>=20
> This patch adds some helper functions to make sure that a destructor is=

> properly defined when a sock reference is assigned to a CAN related skb=
=2E
> To create an unshared skb owned by the original sock a common helper fu=
nction
> has been introduced to replace open coded functions to create CAN echo =
skbs.
>=20
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> Tested-by: Andre Naujoks <nautsch2@gmail.com>
>=20
> ---
>=20
> The patch applies properly down to Linux 3.9. For older kernels the inc=
lude
> file include/linux/can/skb.h would need to be created.

Should I add stable on Cc when applying this patch?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--WA6A5mqktXmbQBJ6IkS0PDHfQt7VhEOHV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLqGjgACgkQjTAFq1RaXHP12wCfTBGnc0j+Wzyq72n6XZyiXVxq
yYEAn2zOf7PNKLyuWppYyDz3VdAKQOYq
=onaU
-----END PGP SIGNATURE-----

--WA6A5mqktXmbQBJ6IkS0PDHfQt7VhEOHV--
