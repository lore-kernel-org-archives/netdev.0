From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ath: wil6210: Fix build error
Date: Mon, 22 Jul 2013 02:45:43 +0100
Message-ID: <1374457543.16248.8.camel@deadeye.wl.decadent.org.uk>
References: <1374374808-12768-1-git-send-email-Larry.Finger@lwfinger.net>
	 <51EBFABB.8080701@lwfinger.net> <1559869.yu0fjJXVeX@balsa>
	 <5330916.8NnOO4SNAp@lx-vladimir>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GnwfA4ZuOTPreBrfd/Zz"
Cc: thomas@fjellstrom.ca, Larry Finger <Larry.Finger@lwfinger.net>,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, wil6210@qca.qualcomm.com,
	Stable <stable@vger.kernel.org>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5330916.8NnOO4SNAp@lx-vladimir>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GnwfA4ZuOTPreBrfd/Zz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-07-21 at 18:52 +0300, Vladimir Kondratiev wrote:
> On Sunday, July 21, 2013 09:35:40 AM Thomas Fjellstrom wrote:
> > If it helps, I'm running a fresh install of Debian Sid with gcc 4.8.1. =
I've=20
> > noticed that each newer successive version of gcc gets more strict with=
 what=20
> > code it accepts without warning, or error. A lot of my only somewhat ol=
d code=20
> > tends to have a lot more warnings. Especially that signedness warning.
>=20
> Yes, this is the case; I have 4.7.3
>=20
> >=20
> > It also looked like that that driver or section of the kernel was compi=
ling=20
> > with -Werror. I haven't verrified that but I remember seeing "treating =
all=20
> > warnings as errors" at one point.
> >=20
> You are right, I have this in Makefile:
> (if one turn on extra warnings with -W, there will be lots of false alarm=
s,
> that's why this ifeq())
>=20
> ifeq (, $(findstring -W,$(EXTRA_CFLAGS)))
> 	subdir-ccflags-y +=3D -Werror
> endif

This is a pretty weird thing to do, and you've failed to account for
-Wextra.

-Werror is generally a bad default in free software, as you have no
control over which compiler version will be used.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-GnwfA4ZuOTPreBrfd/Zz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUeyOx+e/yOyVhhEJAQpy6A/+OUDbZP0eYSrz+bVkh1mxG2V9DS0gnVrM
RiPCC/vtya0U1GjuvMKpjvqSXGBEAHCWs4nfty6r+X+9OVgtdZqYRbnw6KNgqpqX
UvL+yVkT8oqb42GzlL03QTTlsiOggCGmsbdJp7x46gghg4wVCWNHmZRVSIQ2Ce+x
RqU9XbfqLs8DH51RqBYylqUrHrrQwDJj2t9oHuznLJkpfxggJDC9GEZtz+N2+NX9
8iI2qTZpXsfGMi8INLGZ+PvbI5T5hM9D72SUBxZUMxV3qkSzSGHgSFqbcGGzNZJK
xAH/hwhwppDKKngeCJ2quZwZofOypXVGSUUlux77l1aEJb44DNknFbaH8Bd+fGME
OLSjP1bBG2o2otRTvKSDoK/U2tEeYXPIzDNx6fVoVIgnxHm2EQDv115v0R9UPJHF
NcdS/fNLpiUDIQFzDBKbxry+O0wGc3jEWdyLX2ZjwRPZp3hJ530iMxLke8RxR8yO
SA/rSHZvGuJsK3nrqVV50/krarovET8GRtmZRfk9MpLgQ8bxyUJ8geOGQSiaWWjH
8vTBVh+hHtDPhs6l8uMpMflSg9ku8DSCBSoZC1pzKzkczabSDIYTazmInspsarU8
nR+w1gokbsY/0bJVXbJZb0KZnfX1r/ksvGnuy6R+DybBQiKSsqJoCd09m5qa90M7
VxkxjcCRljA=
=4NhL
-----END PGP SIGNATURE-----

--=-GnwfA4ZuOTPreBrfd/Zz--
