From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 1/6] The file ksz_common.c will be used by other KSZ
 switch drivers.
Date: Fri, 8 Sep 2017 10:57:40 +0200
Message-ID: <20170908085739.GD16834@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218C4@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD411219FF@CHN-SV-EXMX02.mchp-main.com>
 <20170907212449.GQ11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41121AFB@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="ylS2wUBXLOxYXZFQ"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121AFB@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ylS2wUBXLOxYXZFQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> > > Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> > > ---
> > > diff --git a/drivers/net/dsa/microchip/Makefile
> > > b/drivers/net/dsa/microchip/Makefile
> > > index ed335e2..0961c30 100644
> > > --- a/drivers/net/dsa/microchip/Makefile
> > > +++ b/drivers/net/dsa/microchip/Makefile
> > > @@ -1,2 +1,2 @@
> > > -obj-$(CONFIG_MICROCHIP_KSZ)	        +=3D ksz_common.o
> > > +obj-$(CONFIG_MICROCHIP_KSZ)	        +=3D ksz9477.o ksz_common.o
> > >  obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+=3D ksz_spi.o
> >=20
> > Hi Tristram
> >=20
> > I would of thought this would break the build. You don't add ksz9477.c =
until the
> > next patch.
> >=20
> > Each patch needs to compile, otherwise you break git bisect.
> >=20
> >      Andrew
>=20
> Eventually the file will need to be broken in two, so you would like
>to see all 3 changes (Makefile, ksz_common.c, and ksz9477.c) in 1
> patch file?

Yes please.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--ylS2wUBXLOxYXZFQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmyW4MACgkQMOfwapXb+vJKoQCcDcJeQxafzQxcmkPCyNT0XuFX
aOoAoI0sLO0sxHRN5CGbECQShwNayxQE
=8q8h
-----END PGP SIGNATURE-----

--ylS2wUBXLOxYXZFQ--
