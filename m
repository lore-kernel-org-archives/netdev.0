From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH][v3.2.y]  inetpeer: Invalidate the inetpeer tree along
 with the routing cache
Date: Sat, 31 Aug 2013 23:04:18 +0100
Message-ID: <1377986658.21578.5.camel@deadeye.wl.decadent.org.uk>
References: <5213A8BB.5070309@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-N9/V2Bzc3Bj8e19dL5xk"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	stable@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5213A8BB.5070309@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-N9/V2Bzc3Bj8e19dL5xk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-08-20 at 13:34 -0400, Joseph Salisbury wrote:
> Hello,
>=20
> Please consider including mainline commit 5faa5df in the next v3.2.y
> release.  It was included in the mainline tree as of v3.3-rc7.  It has
> been tested and confirmed to resolve
> http://bugs.launchpad.net/bugs/1205741 .
>=20
>=20
> commit 5faa5df1fa2024bd750089ff21dcc4191798263d
> Author: Steffen Klassert <steffen.klassert@secunet.com>
> Date:   Tue Mar 6 21:20:26 2012 +0000
>=20
>     inetpeer: Invalidate the inetpeer tree along with the routing cache
>=20
>=20
> Also note that commit 5faa5df introduced a race condition that is fixed
> by mainline commit 55432d2, so that commit would also be required:
>=20
> commit 55432d2b543a4b6dfae54f5c432a566877a85d90
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Tue Jun 5 03:00:18 2012 +0000
>=20
>     inetpeer: fix a race in inetpeer_gc_worker()

David, could you ack/nak these for 3.2 (maybe 3.0 as well?).

Ben.

--=20
Ben Hutchings
If God had intended Man to program,
we'd have been born with serial I/O ports.

--=-N9/V2Bzc3Bj8e19dL5xk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIVAwUAUiJoYue/yOyVhhEJAQrk6BAAzdYpSoV7QjvEsg376PWmHhYJuCvqeGjW
E/2HgvZDMfnn8oMKjKKQgSjb8nZf76tEKeRgOPHg/ZU7NAG1THgphSmst+64Tl0f
lW6e4j8GYZfSGIa1kuTtbQLn96uLN70GOZR6+GBrEcujxJQEiQsB7t7dvsGBzYQ7
jpMAeT9lBBGCv4jKjioX6mGkBmCU1KpgBuaDD0kUxV/qwyI6tKsCg1XrjAcYscJ6
M595R0Z+FKQIKHIbuysQz9rISRirJj7tvetWVL+Q9L9Nd08QuaykJg8+qiIJshH2
37hmcBf9VamAEmah/QGjAXIC9ZmuiRCcEpZYaoEGOpHQtlwKvSaOBnKf2BxpQvQO
9Q5Ad4SmB/JWMjfuZhfsT9m5GfGjXzoaBnFkBVJdee8b1qwz3PxRMSIWOuTgmwfb
rzgvjoF/+8YRkESMmZ0nA8R+VSTYqCEdlv09AqKb2KfbscZRJpZPcTborY3CoHFF
k1PadPlnM9FMSAplELcdh+H6P6OER5aBu7M9P54SWyU7Iy62J2bQW/wkBZSiGCJ8
RlqoMJTCnuqKYfB90MDjn4Vlfo8rmpTHj89mno5Mk4Fe0Drufwpp+UI27flnuAZU
UWIxTB83ApK7bDiTkBkYDDDGbwsNJrxPb11Ule7jbFQLW0uUJXBGs386RoTWJ92P
nyFPBKWQt2o=
=5kOe
-----END PGP SIGNATURE-----

--=-N9/V2Bzc3Bj8e19dL5xk--
