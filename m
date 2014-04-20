From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH [iputils] 4/5] fix handling of CFLAGS
Date: Sat, 19 Apr 2014 23:01:55 -0400
Message-ID: <10018089.GvaJH1c73e@vapier>
References: <1397918597-8680-1-git-send-email-vapier@gentoo.org> <1397918597-8680-4-git-send-email-vapier@gentoo.org> <0e78909d2b809896ca107d86593ed353@ixit.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart8403675.xTtYoaEIg9"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: David Heidelberger <david.heidelberger@ixit.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:51627 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755193AbaDTDBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Apr 2014 23:01:50 -0400
In-Reply-To: <0e78909d2b809896ca107d86593ed353@ixit.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart8403675.xTtYoaEIg9
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Sat 19 Apr 2014 20:55:17 David Heidelberger wrote:
> I'd like to set CC if is unset, check this patch, if it look sane for=

> you :)
> https://github.com/iputils/iputils/commit/77ab88974eb4424620e4caa1dcd=
4bebe02
> 0a3b4e

unfortunately that won't do anything.  make provides a default CC so th=
at code=20
will effectively never get used.

you could just delete the line.  realistically, the default (cc) is goi=
ng to=20
be gcc on any system where this code is built.

alternatively, you can use the pattern:
ifeq ($(origin CC),default)
CC =3D gcc
endif
=2Dmike
--nextPart8403675.xTtYoaEIg9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJTUzijAAoJEEFjO5/oN/WBzF0P/i9mCopIlNUNaFtSxbhVqyag
JcDQjDFORjihJ4d2VOA12Vh3d2zu13cUfpkRzK7yQ/vvE1IAIxC8KYgHU9THSfcV
STo3+ix9wCwYol7di2klE/8U3fAlRMb0PF2+HOs2ditHa6Iu6wLu+LsxIOJ4mT6Q
Y3i129VzyBbbpeEDSWwMKcfHNgSyUq4qFks4eXoBmG4tUyFKllgpdz8FTmW0EOO0
9bVHyUQCy0HhFX5fxqUSWkWkbxMBc37BQVsg1z2o6+1jaN8bvE4jU8sRkqjCL0EE
NZyrnKn8Ip+K1xROMsUa0f2LGP0FJnZJdN3VJPkPkFLe1W84Qbb+FXmlOhpz4wcP
4UIqohTz4El28SMuNhVx0BQLCVzp/u4U5y/PdOcaTZ0ZtsdSMdYpiHBZeFRcEu9t
1FQPdv/ks5Gh2FTAbtpu9A4hnux3+/zvg80KO0ZsvsDg6Pi4tTG0tFV6AVaLVgaZ
QuUC3lBXOFtjthKiseY+cV7xasb0ETzmUXOEvrefPi4Rbm09pPwP+pHgze6BLD2l
m0ZoGnQvMVP+vuLESnghRj7It1DtLOyzEkSo9yO4HQf56bg22Vc4W+siPrtXMeSh
S9ROYS8DLnJfLDE6jsbt9NWF2l+JB4KRfAEG6YGEmSL0l0v8hDmklEOUfMz2dFKz
htJHd0hupdaYbT6+pY9k
=EOKY
-----END PGP SIGNATURE-----

--nextPart8403675.xTtYoaEIg9--
