From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 2/5] Add KSZ8795 switch driver support in Makefile
Date: Fri, 8 Sep 2017 11:06:28 +0200
Message-ID: <20170908090628.GA17738@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A80@CHN-SV-EXMX02.mchp-main.com>
 <20170907215551.GV11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41121B0A@CHN-SV-EXMX02.mchp-main.com>
 <20170907224309.GZ11248@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Cc: Tristram.Ha@microchip.com, muvarov@gmail.com,
        nathan.leigh.conrad@gmail.com, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Woojung.Huh@microchip.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170907224309.GZ11248@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2017-09-08 00:43:09, Andrew Lunn wrote:
> On Thu, Sep 07, 2017 at 10:29:34PM +0000, Tristram.Ha@microchip.com wrote:
> > > -----Original Message-----
> > > From: Andrew Lunn [mailto:andrew@lunn.ch]
> > > Sent: Thursday, September 07, 2017 2:56 PM
> > > To: Tristram Ha - C24268
> > > Cc: muvarov@gmail.com; pavel@ucw.cz; nathan.leigh.conrad@gmail.com;
> > > vivien.didelot@savoirfairelinux.com; f.fainelli@gmail.com;
> > > netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Woojung Huh - C=
21699
> > > Subject: Re: [PATCH RFC 2/5] Add KSZ8795 switch driver support in Mak=
efile
> > >=20
> > > On Thu, Sep 07, 2017 at 09:17:10PM +0000, Tristram.Ha@microchip.com w=
rote:
> > > > From: Tristram Ha <Tristram.Ha@microchip.com>
> > > >
> > > > Add KSZ8795 switch support with SPI access.
> > > >
> > > > Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> > > > ---
> > > > diff --git a/drivers/net/dsa/microchip/Makefile
> > > b/drivers/net/dsa/microchip/Makefile
> > > > index 0961c30..0d8ba48 100644
> > > > --- a/drivers/net/dsa/microchip/Makefile
> > > > +++ b/drivers/net/dsa/microchip/Makefile
> > > > @@ -1,2 +1,4 @@
> > > >  obj-$(CONFIG_MICROCHIP_KSZ)	        +=3D ksz9477.o ksz_common.o
> > > >  obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+=3D ksz_spi.o
> > > > +obj-$(CONFIG_MICROCHIP_KSZ8795)	        +=3D ksz8795.o ksz_common.o
> > > > +obj-$(CONFIG_MICROCHIP_KSZ8795_SPI_DRIVER)	+=3D ksz8795_spi.o
> > >=20
> > > I've not tried it, but i think this breaks the build
> > >=20
> > >      Andrew
> >=20
> > So you would like to have all 5 patches in 1 patch file?
>=20
> Or maybe this one last? Would that stop the build from breaking?

This and Kconfig change should come together.. and probably last.
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmyXZQACgkQMOfwapXb+vIlXgCfSD8SFDZgxMKUfeengDfnXfLL
rSMAn0HB+fJoqh/HLKmFAEcdrW4hdGsg
=9tSn
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
