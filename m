From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] usbnet: Do not implement ethtool get_link() if link
 state is unknown
Date: Wed, 04 Nov 2009 03:20:00 +0000
Message-ID: <1257304800.3136.452.camel@localhost>
References: <200911022201.30950.david-b@pacbell.net>
	 <20091103.010129.100672838.davem@davemloft.net>
	 <200911030141.27905.david-b@pacbell.net>
	 <20091103.020444.120631587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-2PIckiQ1MBjc5L493sQq"
Cc: david-b@pacbell.net, greg@kroah.com, jacmet@sunsite.dk,
	steve.glendinning@smsc.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35854 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753946AbZKDDUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 22:20:09 -0500
In-Reply-To: <20091103.020444.120631587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2PIckiQ1MBjc5L493sQq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-11-03 at 02:04 -0800, David Miller wrote:
> From: David Brownell <david-b@pacbell.net>
> Date: Tue, 3 Nov 2009 02:41:27 -0700
>=20
> > On Tuesday 03 November 2009, David Miller wrote:
> >> All kidding aside, I think the alternative is for the USB network
> >> driver to call ethtool_op_get_link() if it cannot determine the
> >> link state in hardware.
> >=20
> > There's usbnet_get_link() which does just that.  But
> > there may be some ancient debris confusing things.
>=20
> It's perfect, and Ben's patch is completely unnecessary.

I don't see how it's 'perfect' since it reports the link as up where it
is really unknown.  Still, this is a fairly minor bug.

Ben.

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u

--=-2PIckiQ1MBjc5L493sQq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASvDy2ue/yOyVhhEJAQJCqA/+LaK/3onekabQUisV+AxC3L00i2eIKa4j
kkN6NHKGelyo/ZZmdXRha+DTXug7Q68rTdnBPyiuZrQ0DUsBE19X6vngHu2mT8ql
U9CF+Kpl9B/M4JN3DjEKhpPvPp3u3gQAhKg955OsrPjuoqgvuuVjvtOEdit2i8zx
krHQnQBVHNFbtL/MzEt30w6xDgE6uVpZ/ucyeIAsV3GmDtMjMxZVY5D1a7oDHt6o
yU4m2Rv8WqNFV4cEEQMywri06wNex7LheJpZiYcHyehRpNmx3wxcgqscf/uR/ezu
7U4EgxFHTLSctA0rgk0RwxAlwGjsU9Ayc7sMmpz2Bc3w9qpUSDDqABCjeWbZPkrq
TJwOpMqWaKZXv2hRYHc0OUf1dJh3HMZUQ4oiPvjib+TY8eY98KpIP29TxBwLk4dk
aXyYPSJS8Y4QAtGzh1EnMf5ZBFm2ssIMoywo+rUMVIJwQP6PMlhionbo2DsTfYiY
jTVpEx8mps+KOcjYbs5iaAf5xGeQetpRi94G/zbcdRFKn5GvdC5NXJ3Nd/7fbkCH
2VhN+o/hitnNnKE8HdX46wd9SAmOk5e8h035X5On96dhnZ5SBa+FYWLR/ag/mBcQ
kTLY+1hGaGBYLbFEHGMO0jXRyeSQKqhOTo8EwwLRguu1VDPaaAgYu2pxzTpl2MeQ
hysB+mWNO5g=
=AJVT
-----END PGP SIGNATURE-----

--=-2PIckiQ1MBjc5L493sQq--
