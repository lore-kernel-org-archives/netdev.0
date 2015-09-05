From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool V3 1/2] ethtool: Add copybreak support
Date: Sat, 05 Sep 2015 10:50:01 +0100
Message-ID: <1441446601.13323.6.camel@decadent.org.uk>
References: <1434024928-33177-1-git-send-email-hadarh@mellanox.com>
	 <1434024928-33177-2-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KI0Pkp9ua8J6vioNs4ra"
Cc: netdev@vger.kernel.org, _govind@gmx.com,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45414 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754717AbbIEKlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 06:41:40 -0400
In-Reply-To: <1434024928-33177-2-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KI0Pkp9ua8J6vioNs4ra
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-06-11 at 15:15 +0300, Hadar Hen Zion wrote:
> From: Govindarajulu Varadarajan <_govind@gmx.com>
>=20
> Add support for setting/getting driver's tx/rx_copybreak value.
>=20
> Copybreak is handled through a new ethtool tunable interface.
>=20
> The kernel support was added in 3.18, commit f0db9b07341 "ethtool:
> Add generic options for tunables"
[...]

So why have you sent a patch that only handles copy-break?  The kernel
tells us the type of each tunable and ethtool should use that to decide
how to print and parse values.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.


--=-KI0Pkp9ua8J6vioNs4ra
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVeq6yee/yOyVhhEJAQqSQBAAoaJOz0jGuns9byYpxbXIGSCEcCJDb68X
rUrMozGMxInsOAcy212LRI/li1VoFiUDP3ovGf5diLtRIOTtVS+U3goQHVBNwaws
SO1b8D9aSsy1UyZmqlJEjA5gKiCjRK1dzIw3kCoe4D0Chuz2ZdhTdRHW3oSeG+ZT
xGSMkht82jke+fpZHe3ZTkKgOJgrW7EG+A3zWcmJcgySObKGEh23zjXqks7WGYgf
oUVEAPxG0P5o2Y2tJB6Elh/5tEBYbkgX2NmbBRVKA0WKHc+LyIFkcvILrZMTZzYS
GLts8ct/RhT7/9f4VeaDJjypgtlrKpO81eX5NWekyQNj63W0I7EPmvsW1QVSjEV3
UiPe1gPOS6ZXbhI7T3VJ1mgBg/DFZXlXq76sZQc/e+zGzJ/VyU8NyJe1EY3iRU0u
HJ72/VDJkl6Fe2CJw6L1yxicsY3bmHy075kAhyYGHGzkJzRgd8lG8Perfh+z+dKJ
RWGUFb+F6ts5b0G7PPT4vGwO9VIr9WsF83Zr3n9db51pqVyCz8Jg62pe6LV8NmXs
36WJALukrrO+1Caz+ePbEZuUbRPy90VjIcYPYahnCOq5fh/6PSQzJxuJNUs9rqT3
tE7lXAhsIMDXwSkeLJO+72ZEGEgSvnw1bBJ2gw6JJY09ciXvvyHIyPvVuFM60G5x
vHQa1XpZbXM=
=ExbT
-----END PGP SIGNATURE-----

--=-KI0Pkp9ua8J6vioNs4ra--
