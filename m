From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH linux-firmware] linux-firmware: bnx2: Update mips
 firmware to fix iSCSI problems
Date: Mon, 26 Dec 2011 19:31:28 +0100
Message-ID: <1324924288.14957.4.camel@deadeye>
References: <1324268012-27719-1-git-send-email-mchan@broadcom.com>
	 <1324457726.2728.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <0E685F8B314BFB42AE2422915B7BDCC30752F5@IRVEXCHMB07.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-W4LuqimJYRc31c53oJdy"
Cc: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	"'dwmw2@infradead.org'" <dwmw2@infradead.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42250 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751276Ab1LZSbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 13:31:47 -0500
In-Reply-To: <0E685F8B314BFB42AE2422915B7BDCC30752F5@IRVEXCHMB07.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-W4LuqimJYRc31c53oJdy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-12-21 at 16:49 +0000, Michael Chan wrote:
> Eric Dumazet wrote:
>=20
> > Le dimanche 18 d=C3=A9cembre 2011 =C3=A0 20:13 -0800, Michael Chan a =
=C3=A9crit :
> > > New firmware fixes iSCSI problems with some LeftHand targets that
> > don't
> > > set TTT=3D0xffffffff for Data-In according to spec.  Firmware generat=
es
> > > exception warnings for this condition and becomes very slow.  This is
> > > fixed by suppressing these warnings when using default error mask.
> > >
> > > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > > ---
> > >  WHENCE                      |    2 ++
> > >  bnx2/bnx2-mips-06-6.2.3.fw  |  Bin 0 -> 92824 bytes
> > >  bnx2/bnx2-mips-09-6.2.1b.fw |  Bin 0 -> 103904 bytes
> > >  3 files changed, 2 insertions(+), 0 deletions(-)
> > >  create mode 100644 bnx2/bnx2-mips-06-6.2.3.fw
> > >  create mode 100644 bnx2/bnx2-mips-09-6.2.1b.fw
> >=20
> > IMHO, this should be applied _before_ the drivers/net patch.
> >=20
>=20
> Ben,
>=20
> If David Woodhouse is not available, can you help us apply this firmware
> patch?

Applied and pushed out.

Ben.

--=20
Ben Hutchings
Knowledge is power.  France is bacon.

--=-W4LuqimJYRc31c53oJdy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATvi9gOe/yOyVhhEJAQo6JA/5AcYcDiXABUbAKPi747lbNs0B8KRdyAHj
88ps9dPxtRT8c3jHHu/SnvbjFyvfdQls+hWcZCM78DraHX9GIEmOZsohKLRYM+zG
5quAhsIG6FO72DdH2wFTxD85iTRaij/jHy6XxCz0ZxVurGZ4KsDuTg6+M4BmG6CR
GoB2JOpgkNK0qMURCLb5N8qvx70/PF6ywVsVfmSdd2ZZYsCv67fE/AktL6XZ/j2k
E6daBTzgTVXV67dTLzWI3behGY0a5dD+tn/tBF/ifkmFtOhqlJTzmoFlQ0kZD+O3
L/d3J95UvVgi5PfqHq4MuKUZAGAtfajF+b/WQes5zAGPt+J9f41FHlmhwFhfxLqd
2mkH41UW6QMjqAUfDYCOuBZtiZbH4Kx7OZxW7LGHS/SDYR+3p7RVM/FoWsgVFciK
VR0V0rOVj69NCuIaScsLExK6jM+lhRhm1ZoLT/CfVjyQj8cODBzL9r5E3ZRTky5/
laSuaFysMQd4T8ls6JYiB5lZNqxwt/AFz1u7TdsA56DuWexdUWdUVVBdOntHqFx/
d9VssFWK1qzs/6u2KfR/I+mtKWrcWd0aY6dGJuJVxa7Z5UwFsi8NwP8ctm/cDUxj
eoBj4G303mkO7cK6lG8nYYmzsz039VbNy/L1S5uTZGEfiYqHOsKLbSHfvk5y9Jwn
R82CAXPqlzY=
=t9ge
-----END PGP SIGNATURE-----

--=-W4LuqimJYRc31c53oJdy--
