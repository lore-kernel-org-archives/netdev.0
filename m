From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when
 able to sleep
Date: Sun, 26 Sep 2010 13:46:19 +0100
Message-ID: <1285505179.2697.210.camel@localhost>
References: <20100924222434.GA7743@electric-eye.fr.zoreil.com>
	 <20100924.223709.233700415.davem@davemloft.net>
	 <1285394797.2478.54.camel@edumazet-laptop>
	 <20100925.001300.193725148.davem@davemloft.net>
	 <1285405945.2478.255.camel@edumazet-laptop>
	 <1285457597.2697.183.camel@localhost>
	 <1285481398.2436.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-uxCj07otv/cQWSa3aZXS"
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47171 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757696Ab0IZMq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 08:46:27 -0400
In-Reply-To: <1285481398.2436.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uxCj07otv/cQWSa3aZXS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2010-09-26 at 08:09 +0200, Eric Dumazet wrote:
> Le dimanche 26 septembre 2010 =C3=A0 00:33 +0100, Ben Hutchings a =C3=A9c=
rit :
> > On Sat, 2010-09-25 at 11:12 +0200, Eric Dumazet wrote:
> > [...]
> > > The r8169 current problem is its currently copying all incoming frame=
s.
> > > I guess nobody cares or noticed the performance drop.
> > > (But commit c0cd884a is recent (2.6.34), this is not yet in
> > > production...)
> >=20
> > Since that was a security fix it was backported to 2.6.32.12 and
> > probably most distribution kernels.  So yes it is in production.
>=20
> Maybe in your company, not a single machine in mine ;)
>=20
> Most linux servers in production run much older kernels.
>=20
> rhel 5 -> 2.6.18
> debian 5 -> 2.6.26.x

Those both have the fix.  Look for CVE-2009-4537 in the changelog.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-uxCj07otv/cQWSa3aZXS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATJ9Alee/yOyVhhEJAQKPtA/+K+8ydO4w0HF76HBZ3MvKwRmpOU5zXXJv
7tULHlD8dMGZQo4QlNHDxIAqp/8XZb491yh/HSnDKiHyt9d5ePpCiv+Yc0vSpx6X
1JzYcRNt+riH+NQRYoI8ynspYkF5EUDs+uu7ZgEQnHVIFl5mjJSd3+bEXH48//6J
4n0Vtmzrl3+iawT04gu9Jh+ssS+D7WbdQI1LVihjAs8C3xhYh+oWnKUQXPy8Qk1G
R7U7BhiegK/m5vcTDKNMgGO9nZdDPkPcPZrmGkFUaM3YD6ecEiMWGAo6QoFY07Kk
6h0RuKmp0alDia4Nqn+RzvYB7HRcu7IApKnI4CjODP5XghAQnMhxWXOTNY4RkODE
a/TV4kcr+KjXD26i1plZwg5gCpxLXLUBER9lGjpVXyRuyBsvGamHIQ0bwzefGlzd
VppRr9/YarfYuWQh/R7OFBHS0iXYBmYIT0NnrM3qylNV6U/cawkpKmFcGDE/1wGu
Gx32LzNiadFq4+Bo/o8VwzyloVLMkEyEfy17Cju65EsUqGdyvRHVtp7YZbeNCpM8
0irqtLqeM1aBmvxeLIYRVuwidtomNsl3KXPLV9dHvypSV5Ni0aHkvugqdZyK5mot
ziWaZJU8Ye44xnwOD2DOLcPNQ2LOKfqgwD7aNBPKU06qRXEuskGCkZiGAzVKzes9
4lZ+6FMISig=
=Qthg
-----END PGP SIGNATURE-----

--=-uxCj07otv/cQWSa3aZXS--
