From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] phy: SMSC: fix unused warnings when built into kernel
Date: Fri, 6 Aug 2010 03:37:56 -0400
Message-ID: <201008060337.57627.vapier@gentoo.org>
References: <1281076034-17390-1-git-send-email-vapier@gentoo.org> <AANLkTi=_-ZZ8nyFLiBKSWNTcM_SkwLe2-ZL17zBQb0i4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4455575.0AHa8dliqd";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38277 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933894Ab0HFHhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 03:37:20 -0400
In-Reply-To: <AANLkTi=_-ZZ8nyFLiBKSWNTcM_SkwLe2-ZL17zBQb0i4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart4455575.0AHa8dliqd
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Friday, August 06, 2010 02:43:46 Changli Gao wrote:
> On Fri, Aug 6, 2010 at 2:27 PM, Mike Frysinger wrote:
> > If the SMSC phy is not built as a module, we get the warning:
> >        drivers/net/phy/smsc.c:257: warning: 'smsc_tbl' defined but not
> > used
> >=20
> > So mark the structure as maybe unused to avoid this.
> >=20
> > --- a/drivers/net/phy/smsc.c
> > +++ b/drivers/net/phy/smsc.c
> > @@ -254,7 +254,7 @@ MODULE_LICENSE("GPL");
> >  module_init(smsc_init);
> >  module_exit(smsc_exit);
> >=20
> > -static struct mdio_device_id smsc_tbl[] =3D {
> > +static __maybe_unused struct mdio_device_id smsc_tbl[] =3D {
> >        { 0x0007c0a0, 0xfffffff0 },
> >        { 0x0007c0b0, 0xfffffff0 },
> >        { 0x0007c0c0, 0xfffffff0 },
>=20
> How about adding a #ifdef CONFIG_SMSC_PHY_MODULE clause  around these
> lines?

imo, the less ifdefs the better
=2Dmike

--nextPart4455575.0AHa8dliqd
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iQIcBAABAgAGBQJMW7vVAAoJEEFjO5/oN/WBsDYQAJvlzUGjLKdaEWM+ZPjOmB2n
N3Ry549l9StUTOgWZWUmjVG5tynDcpzVJ/Vb0lIOJwE4z+D1+Z9Ln28RKvSw3fo/
gujiyYmnypKiIc0MoRk/8sd0ReRLpBOZ6HqUs/e99eDtzv/7OobGFNahiioXFILf
RYv+pUilyjoFzXPT6j4IM3+H1hc3D7lWhqqPqMZ1LIznI5ihf3v0HO09XnwhQEes
4U5yyTlAvlE25vNuTvOkSYAlGjD7x8Drlo9wklVX/enriXmJVKE6FVaNQFYACCZq
OgSY+D8LLf8qdmu/i7q+rjwykfdA+Gsh5cWrD0KU4iReFbNmyleznNyWEeEWrwt9
ihmC0qjUutYwUj8MMfJutsrlAHUKF7Nlhx0weEfixbf7PAMUWvCh2L2NtUw1nWTk
kqSHIxg2eyct0TyVcCz/PkIPGNPPMeO8WsSWV5Vhny3y3yBHxjusbQhiJpuluVsS
dE9KyNGFWj1+j1n4dobkfBVRCGb5GKvxjjb22gRR+dMYu2AoerzmLHYsxoGON18l
qLY39GElsOtk3iKqQxxXxlUNIi9pghO6qkg7Sm1YbsENY46qJ2KDz1RMhAyaxC+U
YnK3/9pBLmQLiXlkP/J4eQIQTvP/I5/a2mmadqOjSL5ZGFYUp+7Uqsz4YmTIqg4s
mQtyDu0IFd1VCltpbY9r
=vA8N
-----END PGP SIGNATURE-----

--nextPart4455575.0AHa8dliqd--
