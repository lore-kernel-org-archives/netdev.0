From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3/3] dm9601: add support ethtool style utility
Date: Fri, 11 Mar 2016 11:33:33 +0000
Message-ID: <1457696013.3001.86.camel@decadent.org.uk>
References: <201603111110.u2BBAiwV020429@mail.davicom.com.tw>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dVzdfGanHawhL6i7j95W"
To: Joseph Chang <joseph_chang@davicom.com.tw>,
	'Joseph CHANG' <josright123@gmail.com>,
	'Peter Korsgaard' <jacmet@sunsite.dk>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60326 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752086AbcCKLdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 06:33:49 -0500
In-Reply-To: <201603111110.u2BBAiwV020429@mail.davicom.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dVzdfGanHawhL6i7j95W
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-11 at 19:08 +0800, Joseph Chang wrote:
> I tested by
> =C2=A0./ethtool -E eth0 magic 0x9620 offset 0 length 3 value 0xf1 value 0=
xf2 value 0xf3
>=20
> I think ethtool need [ value N ] for each byte (so need three "value xx" =
in above command line),=C2=A0
> am I right?
>=20
> Oh, I can see it goes wrong~ Thanks~
[...]

You can only pass one byte on the command line and that forces the
length to be 1. =C2=A0To set multiple bytes, you need to provide them on
stdin instead.

Ben.

--=20
Ben Hutchings
73.46% of all statistics are made up.
--=-dVzdfGanHawhL6i7j95W
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW4q0OAAoJEOe/yOyVhhEJ3A0P/1ZVAGMPPLJbjAqeTDN0oPQ5
1rJS7UDMdl6oEMY+ph89CUg3ruMSqFqbhGxbq/Hxd6JGT7+fqla+LvHluQGFYXAM
JE3WqVLD2lcvkYzygG4+eK5rz3GBn6B7TT0JW+vjP4jub6qOUYv+dHxup9RpHiXm
tMD/IyVerwW/yhlMHYHhO4LSc5o7XSpjHUuhcHNIn4efUIHG5moa8SSU34J1CTiu
CNM9Z++WY+dRrPBZyGtXgPE6BdWTKdZVTsgozEK8oIMpH0VHhqtbL02JEvV8aJ0L
IXd2dX7gNAKfj8EzAB0WVbmdn772fH3KD6S7bWxACuCZKmeHQc3L3NTDm92qFMTc
AnuOeqDm5yoZBXz8JSuxv67koewK0Tsj3nk4MD1zWlcyKhRBoa6z3zJniGl+hrSX
O1C1tLXVVZqMVMh6osryCCwKEpq456qt1K4R8Hc7vcrB7vY7LHbBmdY1t0oCbsSk
mAMyvcsW87ePeJLN3q0Ay0fW0wI/BnhCBH8Bt8gZf556n1e8lFsDIovWfBP31yQE
rRXVOh8/5oVyuXln39K9/g6fV36z81Xf/XTWs4/HoMKKR2ZMZUC57yEuSyB9Jktf
VYu+wI8x7dti4zStTZWN4AVW3/Dsf865E5vLtixMZcjd/TZiki7hCSa0yJwxkORa
eTtuoEjXLz5CY5gLhjwD
=FQp9
-----END PGP SIGNATURE-----

--=-dVzdfGanHawhL6i7j95W--
