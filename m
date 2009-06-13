From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: refactor multicast/unicast address list
Date: Sat, 13 Jun 2009 14:28:14 +0200
Message-ID: <1244896094.13033.8.camel@johannes.local>
References: <1244889678.13033.6.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-83f81xpIfe4+s9oPp9KW"
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40256 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbZFMM11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 08:27:27 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <johannes@sipsolutions.net>)
	id 1MFSKV-0006mY-O3
	for netdev@vger.kernel.org; Sat, 13 Jun 2009 14:27:28 +0200
In-Reply-To: <1244889678.13033.6.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-83f81xpIfe4+s9oPp9KW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2009-06-13 at 12:41 +0200, Johannes Berg wrote:
> I'm trying to use address lists without netdevs, but as
> a first step I thought it would be good to reduce the
> amount duplicated code between unicast and multicast
> lists.
>=20
> After introducing a new 'struct address_list', we can
> unify a lot between these. The next step will probably
> be exporting the __dev_addr_sync and __dev_addr_unsync
> functions so I can use them without a netdev, but this
> cleanup can stand on its own.

Sorry, this was based against the wrong tree and now I see that in
net-next the lists have diverged significantly. Ignore this.

johannes

--=-83f81xpIfe4+s9oPp9KW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKM5taAAoJEODzc/N7+Qma3c8P/jWaGVv3oFvHkNWifYvM8Q1r
R/bAabJMEtYBxnDceW1ESeYoZAxYSa8fiywCa1ZKXtdthEAEP7TrIGJs1Odgn6oR
a9VFuXaTgPnpJk/jXHBPXuMZwHL2QCVUR9oyEz9CPl6QKSZ45+uz3/5QlWWRwtaU
pwDXaNKvpF11LCnJ0wdaxL0AswAticrt0iunIiGz+SjeRFLJd1q3ZTcTr6ayUnwJ
tm5rZ2mJH1fTCIYt5s9tfzQzS+oW0ciJpxT1zyLMOmVfjAwsbT8A33eoEtl2eVUH
o4GCvv/HjER9aDzbeavp3WTZPqxJT/gF1DdohFO08ADkWbW7FKBlYlLSdTVehWNz
rzp4bLUwq/ST31zANnZKsZDkD7uZ5tXYoXh3USvrHGgwj9PVz88ewaOaGHuWilBt
xSB6zSaCrKB/3ljsZDQTzJnPBZe6Vc3Dqv9n9xt5XYC6859uUXFgJWWWRb+X0jwT
zw4IXZ8XvzEgPh/uyxgxC6qnv2vYvilwlWm08G4d+fViguofpqREniuvb+ADbLgx
7OIobpBy2tHUs/NUuQlzGF09MHgrZEJv4XLMxlE8anP8pDqrtpieVf5aK7+9jQc7
a3UmnK2bFn/Sf6FUeFIgyTkId/xc2RRkBZqiAg1LTWL+ZEsX/2UjK2b+uIGn30oG
NWmJFSJkxxKCZDrcmY1J
=tJgI
-----END PGP SIGNATURE-----

--=-83f81xpIfe4+s9oPp9KW--

