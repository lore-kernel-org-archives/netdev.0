From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: gigaset: freeing an active object
Date: Mon, 7 Dec 2015 19:40:55 +0100
Message-ID: <5665D2B7.3040409@imap.cc>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
 <1448906497.3546.16.camel@tiscali.nl> <565F8341.7010704@hurleysoftware.com>
 <1449408690.2515.15.camel@tiscali.nl> <5664545C.90607@imap.cc>
 <1449432742.2515.20.camel@tiscali.nl> <566550E7.80801@imap.cc>
 <1449491141.3615.11.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="fxLBHE4tjkHjH1KgscKGD1O7r6GX45UMa"
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Paul Bolle <pebolle@tiscali.nl>,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449491141.3615.11.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fxLBHE4tjkHjH1KgscKGD1O7r6GX45UMa
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 07.12.2015 um 13:25 schrieb Paul Bolle:

>>> Otherwise we'd still be freeing memory
>>> managed through reference counting.
>>
>> Now I#m confused. I thought by following Peter's suggestion to put the=

>> kfree() in the release method we'd avoid just that.
>=20
> Apparently it does, because I can't trigger the WARNING we're discussin=
g
> here with your patch applied.

Nice.

> I'll have to dive into this stuff again,
> because apparently my mental model of what's going on is incomplete at
> best.

I won't claim anything like completeness for mine.

> In the mean time you might want to turn your patch into something that
> can actually be applied (with or without my Sign-off or Ack; I don't
> care how it finds its way into the tree). Please add add
>     Fixes: 2869b23e4b95 ("[PATCH] drivers/isdn/gigaset: new M101 driver=
 (v2)")

Will do. (Not today, though.)

Regards,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--fxLBHE4tjkHjH1KgscKGD1O7r6GX45UMa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWZdK3AAoJEFPuqx0v+F+qygIIAKawGf+2ZUYKezSVWs0Q7zHJ
f2uqdnyFf0EgV+qCOqQZoCkcIqs2hEhdcrmIEpstMAgyL6ILcKXWCrwliqvOzv07
uzfOrLA5kTknjBtx5u/i6UiX3TtR0yiZC/qg2UoBxpbSw8joenCjKfYE+yb+KiXn
6DXU1GRe94gl6MGv7YDOVXWebPoUFyodRMQ5KyE5vCvBxGYZ/ET4eBmOLARffDXq
7HAQJ6B830S+RC7d/rmx+Yc8yo1fAzU1rwaH4RK7f2s1K5F+8vdZfdHjS9pbBrmh
OnYUcPpj8XGezQxLJNaS7HUOStsRekA/qdexLaem1SphXGYoUaCpVYlsUm0QbUg=
=AiR6
-----END PGP SIGNATURE-----

--fxLBHE4tjkHjH1KgscKGD1O7r6GX45UMa--
