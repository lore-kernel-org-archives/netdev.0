From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [Cbe-oss-dev] [PATCH 10/10] spidernet: increase the NAPI weight
Date: Thu, 17 May 2007 09:34:52 +1000
Message-ID: <1179358492.4142.5.camel@concordia.ozlabs.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com>
	 <20070516222357.GJ4997@austin.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-f4KJcxp/8rxt3soFu4y9"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56554 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759324AbXEPXey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 19:34:54 -0400
In-Reply-To: <20070516222357.GJ4997@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-f4KJcxp/8rxt3soFu4y9
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-05-16 at 17:23 -0500, Linas Vepstas wrote:
> Another way of minimizing the likelyhood of RX ram from overflowing
> is to empty out the entire rx ring every chance we get. Change
> the crazy watchdog timeout from 50 seconds to 3 seconds, while
> we're here.
>=20
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
>=20
> ----
>  drivers/net/spider_net.h |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>=20
> Index: linux-2.6.22-rc1/drivers/net/spider_net.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-05-16 12:00:35.00=
0000000 -0500
> +++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-05-16 12:00:35.0000000=
00 -0500
> @@ -56,8 +56,13 @@ extern char spider_net_driver_name[];
> =20
>  #define SPIDER_NET_RX_CSUM_DEFAULT		1
> =20
> -#define SPIDER_NET_WATCHDOG_TIMEOUT		50*HZ
> -#define SPIDER_NET_NAPI_WEIGHT			64
> +#define SPIDER_NET_WATCHDOG_TIMEOUT		3*HZ
> +
> +/* We really really want to empty the ring buffer every time,
> + * so as to avoid the RX ram full bug. So set te napi wieght

Speeeling ...................................... ^^ ^^^^ ^^^^^^

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-f4KJcxp/8rxt3soFu4y9
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGS5UcdSjSd0sB4dIRAhTYAKCb2+VUONepK3Izq76b6RTdo1I7zACeLA9d
fXKJjvgtgD6wzELmVorVdqQ=
=6pRY
-----END PGP SIGNATURE-----

--=-f4KJcxp/8rxt3soFu4y9--

