From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH] 3c59x: Don't assign when a comparison is intended
Date: Sat, 25 Dec 2010 23:17:00 +0100
Message-ID: <20101225221700.GA8612@pengutronix.de>
References: <alpine.LNX.2.00.1012252125410.10759@swampdragon.chaosbits.net> <AANLkTi=Y4wDG6+AY1=8NuFLGuCidgqaU1LginfB1YpZH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lrZ03NoBR/3+SXJZ"
Cc: Jesper Juhl <jj@chaosbits.net>, netdev@vger.kernel.org,
	vortex@scyld.com, becker@scyld.com,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	linux-kernel@vger.kernel.org
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=Y4wDG6+AY1=8NuFLGuCidgqaU1LginfB1YpZH@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Dec 25, 2010 at 09:50:56PM +0100, richard -rw- weinberger wrote:
> On Sat, Dec 25, 2010 at 9:30 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> > Hi,
> >
> > In drivers/net/3c59x.c::vortex_probe1() we have this code:
> >
> > =A0 =A0 =A0 =A0if (gendev) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((pdev =3D DEVICE_PCI(gendev))) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0print_name =3D pci_name(=
pdev);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((edev =3D DEVICE_EISA(gendev))) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0print_name =3D dev_name(=
&edev->dev);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> > =A0 =A0 =A0 =A0}
> >
> > I believe these assignments were intended to be comparisons.
> > If I'm correct, then here's a patch to fix that up.
>=20
> I don't think so. Look at the extra brackets.
>=20
> The code can also written as:
>=20
> pdev =3D DEVICE_PCI(gendev);
> if(pdev)
>   print_name =3D pci_name(pdev);

=2E.. which looks much better and could be worth a patch as well.

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--lrZ03NoBR/3+SXJZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk0WbVwACgkQD27XaX1/VRuTRACfWd1/1j2rueStgVeJJxDVb3qT
F1IAniAFUAlpz/PMfkvFRf1HUbWapqBc
=mi1C
-----END PGP SIGNATURE-----

--lrZ03NoBR/3+SXJZ--
