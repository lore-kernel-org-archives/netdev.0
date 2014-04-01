From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Tue, 01 Apr 2014 17:55:15 +0100
Message-ID: <1396371315.22689.9.camel@deadeye.wl.decadent.org.uk>
References: <1395970770.2898.54.camel@deadeye.wl.decadent.org.uk>
	 <20140328.171253.1863144825039621848.davem@davemloft.net>
	 <BF3270C86E8B1349A26C34E4EC1C44CB2C8A255E@CMEXMB1.ad.emulex.com>
	 <20140401.122016.1850526829984133014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mW8ZovYc6Rtv81+yidY3"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, VenkatKumar.Duvvuru@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43998 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751663AbaDAQz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 12:55:28 -0400
In-Reply-To: <20140401.122016.1850526829984133014.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mW8ZovYc6Rtv81+yidY3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-04-01 at 12:20 -0400, David Miller wrote:
> From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
> Date: Tue, 1 Apr 2014 15:19:48 +0000
>=20
> >> > By grouping the key and hash together, with some reserved fields
> >> > (which the setter should initially require to be equal to zero), it
> >> > should be possible to fill in support for numbered RSS contexts late=
r
> >> > without yet another new structure and operations.
> >=20
> >=20
> >> If that is the case, why don't we add from the start a "u32 rss_contex=
t;"
> >> field that has to be set to zero for now?
> >=20
> > The current structure has got three u32 reserved fields already. We cou=
ld use one of them when the support is added.
>=20
> Just do as I said, naming one of those to "rss_context" now, and require
> that it be zero.

I agree, I think that makes sense for the initial definition.

Sorry about all the back-and-forth discussion on this, Venkata.

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-mW8ZovYc6Rtv81+yidY3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzrvc+e/yOyVhhEJAQpQrg//cqT0iu8gqsQzQNFIk3VypI4NAg4VKDDK
EeNkMo/HKqtcSpGBVLrPB/BU4Hq3zRVCINGD+9sD4XKQktVaouogPH5TFu3IbACu
hCu5htb7Xf8QuFlqkPAp7WGEMbwlrPaUPa0QwihHEzQCnxerzGbcHhnvEgNeQxEe
YUjWjiWV23F4TwS0pYrD1YBbSSAqn1z/6z0u5bFc5PgC14Z6Be6PN9G+DV5DywmT
Lb+6cKo0vuib4o4ARRU2G5dW4cLx0X9Vpj5t2thcrzfg2lipgaU+qDhJ2FFBjSJJ
JSUI/XrRDTHmmCvXtGrv9GT3HYO7GU0SFxQe4x2u+JR5pyAgo0iH2zTAY38FrrUQ
ryAzWqdSJre8EYQdM3XmJ8cC/IgJ+5Ke1C2fm8hkZtuOglUKnt7Gwt0mrD1WSX6z
D1u8M37y/VJ6hnh+gDVcw7vA96k/YeoHM3a+b69cvgJEUwh41kdv3stZIPDEk3IE
3CynIZDz+rJNJ7/uNg0WO1IsL1ZO41Inhx/yJJPuBmar9SlUXV/dH1o1oA4WHVvp
HVLYeeVouTLd1F1Uplf1adSrkwSQgigiBndiDWXEkrgBvg9HUlYs8lZQ5EkK2UwR
THuz5aPt98s/RZEf459cJjrHNAPTkPnykAXk6S94HTN8JUqS7RNs5DFk1ujqBr+N
0qEsmm06daw=
=sDBa
-----END PGP SIGNATURE-----

--=-mW8ZovYc6Rtv81+yidY3--
