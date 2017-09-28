From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 0/6] Modify KSZ9477 DSA driver in preparation to add
 other KSZ switch drivers.
Date: Thu, 28 Sep 2017 17:24:51 +0200
Message-ID: <20170928152451.GD2482@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218B7@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD411219F8@CHN-SV-EXMX02.mchp-main.com>
 <20170908085405.GB16834@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41122FFB@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="uxuisgdDHaNETlh8"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41122FFB@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--uxuisgdDHaNETlh8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > >  drivers/net/dsa/microchip/Makefile     |    2 +-
> > >  drivers/net/dsa/microchip/ksz9477.c    | 1317
> > ++++++++++++++++++++++++++++++++
> >=20
> > We already have ksz_9477_reg.h. So should this be ksz_9477.c for
> > consistency?
>=20
> The product name is KSZ9477 and other switches are also like KSZ####,
> so I would prefer to have no separation between KSZ and the product
> number.  I think the file ksz_9477_reg.h was named that way because
> the other files were named ksz_common.c and ksz_spi.c.  If need to
> we can change the file name.

I don't care either way, but please make it consistent.

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--uxuisgdDHaNETlh8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnNFEMACgkQMOfwapXb+vImbACgvlSByGkYwj+hZvPTmJsOnSNV
w9wAoKGy0HWDTMDNisuSyYXmFQfCqQqA
=YIMy
-----END PGP SIGNATURE-----

--uxuisgdDHaNETlh8--
