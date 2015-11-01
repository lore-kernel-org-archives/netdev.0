From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net 1/2] isdn_ppp: Add checks for allocation failure in
 isdn_ppp_open()
Date: Sun, 01 Nov 2015 16:23:51 +0000
Message-ID: <1446395031.25466.1.camel@decadent.org.uk>
References: <1444845074.31451.21.camel@decadent.org.uk>
	 <20151016.004606.1112196816016985692.davem@davemloft.net>
	 <CA+5PVA50ToS+h0ahYAAN_ZG6CHnaxZjzkjKwGW=WWgzxjLT=dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Y3AwySl64tJGqN+83guI"
Cc: isdn@linux-pingi.de, David Miller <davem@davemloft.net>,
	linux-ppp@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Josh Boyer <jwboyer@fedoraproject.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <CA+5PVA50ToS+h0ahYAAN_ZG6CHnaxZjzkjKwGW=WWgzxjLT=dQ@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Y3AwySl64tJGqN+83guI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-10-30 at 09:03 -0400, Josh Boyer wrote:
> On Fri, Oct 16, 2015 at 3:46 AM, David Miller <davem@davemloft.net>
> wrote:
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Wed, 14 Oct 2015 18:51:14 +0100
> >=20
> > > Compile-tested only.
> > >=20
> > > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > > ---
> > > =C2=A0drivers/isdn/i4l/isdn_ppp.c | 6 ++++++
> > > =C2=A01 file changed, 6 insertions(+)
> > >=20
> > > diff --git a/drivers/isdn/i4l/isdn_ppp.c
> > > b/drivers/isdn/i4l/isdn_ppp.c
> > > index c4198fa..86f9abe 100644
> > > --- a/drivers/isdn/i4l/isdn_ppp.c
> > > +++ b/drivers/isdn/i4l/isdn_ppp.c
> > > @@ -301,6 +301,8 @@ isdn_ppp_open(int min, struct file *file)
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0is->compflags =3D 0;
> > >=20
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0is->reset =3D isdn_ppp_ccp_reset_=
alloc(is);
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!is->reset)
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0return -ENOMEM;
> >=20
> > Ben, your email client has corrupted both of these patches.
> >=20
> > Please fix this up and resubmit, thanks.
>=20
> Ben, did you resubmit these as David suggested?=C2=A0=C2=A0I haven't foun=
d a v2
> anywhere.

I've just done so.

Ben.

--=20
Ben Hutchings
Nothing is ever a complete failure; it can always serve as a bad example.

--=-Y3AwySl64tJGqN+83guI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVjY8l+e/yOyVhhEJAQqpWg//eK4oj6yH5992ict0BKWIrfI2tKSXzv84
TfbaW4d4v+IdBUc4st45P87aLp2rmsjurxhy4EK5AhIitzCFb10DOBwJZ70wZZGP
ASFMewS12i5n0aCQch437719bQK/JkgUfc98tmUDi/W02JhYm2TiJ+5KZxMatdtw
Qes0DyiChAaDs1dZYdRC43lDocAuyfD909zq36748X4Oh1szrLiebk74Rppz+QO8
+nsJ2LfLml/p5x0JKU748rooJFoi7a2cqbwwwlymZBhm8iuuoJqnW5n5q4s/FXoZ
WNuMnihL+gSdzguX0xpQjCBVc1Xxk4EArXdko1b2deT+7VcMkHtQJ4z07px8SKeM
GX9+qQTdKE+2wUOw+l2/KdRWoGLlA0voiz1HKfh6dqi+fes3K2P2WtKgkytvLIP4
xi/Bs2K2ZHtG3FfHHl/BSwwFvKaYHuB7GEGTKNTcPCI9HefU54kIiv4rA/yNuE2F
z9KmfawICd9750v5hzzgUmZQp/oPLd1E3EbOJruM++/LcPYq6+bHJiiHBJa8+vsj
8+UjhJ+BS5gHwTb8urc/P0l+mBedCMq973TtGB6VBGXG0oMdWjgI7uTrnDZJUykE
pfECMCJTc8ULvymG0Zi35BbbB01PE6ST195szxnghT574jw/hio/VZV6wfaIYZvh
V4sWGDSzbPQ=
=1QFm
-----END PGP SIGNATURE-----

--=-Y3AwySl64tJGqN+83guI--
