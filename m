From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [Cbe-oss-dev] [PATCH 2/10] spidernet: beautify error messages
Date: Thu, 17 May 2007 09:28:53 +1000
Message-ID: <1179358133.4142.1.camel@concordia.ozlabs.ibm.com>
References: <20070516215605.GA4325@austin.ibm.com>
	 <20070516220011.GB4997@austin.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-gnaTMeB+VV3KCG/a02Hb"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48789 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755714AbXEPX2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 19:28:55 -0400
In-Reply-To: <20070516220011.GB4997@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-gnaTMeB+VV3KCG/a02Hb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-05-16 at 17:00 -0500, Linas Vepstas wrote:
> Make error messages print which interface they apply to.
>=20
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
>=20
> ----
>  drivers/net/spider_net.c |   10 ++++++----
>  drivers/net/spider_net.h |    2 +-
>  2 files changed, 7 insertions(+), 5 deletions(-)
>=20
> Index: linux-2.6.22-rc1/drivers/net/spider_net.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-05-14 17:05:03.00=
0000000 -0500
> +++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-05-15 14:47:38.0000000=
00 -0500
> @@ -433,7 +433,8 @@ spider_net_prepare_rx_descr(struct spide
>  	descr->skb =3D dev_alloc_skb(bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
>  	if (!descr->skb) {
>  		if (netif_msg_rx_err(card) && net_ratelimit())
> -			pr_err("Not enough memory to allocate rx buffer\n");
> +			pr_err("%s: Not enough memory to allocate rx buffer\n",
> +			    card->netdev->name);

Isn't that what dev_err() is for?

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-gnaTMeB+VV3KCG/a02Hb
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGS5O1dSjSd0sB4dIRApHYAJ9cAvFEZMIw22qcojQUJnanTF9T1wCdG1MG
8OdknK2m1Gqbc39R9t0Odgc=
=B2Xg
-----END PGP SIGNATURE-----

--=-gnaTMeB+VV3KCG/a02Hb--

