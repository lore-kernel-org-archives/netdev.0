From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 5/5] Add KSZ8795 SPI driver
Date: Fri, 8 Sep 2017 23:55:36 +0200
Message-ID: <20170908215536.GE27428@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A95@CHN-SV-EXMX02.mchp-main.com>
 <20170908092614.GB18365@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E1C@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="a1QUDc0q7S3U7/Jg"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121E1C@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--a1QUDc0q7S3U7/Jg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > Please format according to CodingStyle. (Not only this.)
> >=20
> > And this will be common for more drivers. Can it go to a header file
> > and be included...?
> >=20
>=20
> Sorry about the formatting.  It seems my e-mail system needs to be checked
> to make sure it does not auto-format the contents again.
>=20
> About the SPI access functions they are the same for each driver except t=
he
> low level ksz_spi_read_reg and ksz_spi_write_reg.  The dev_io_ops structu=
re
> should contain only those 2 and ksz_spi_get and ksz_spi_set.
>=20
> But that requires changing ksz_spi.c.  The idea was to keep the code of
> KSZ9477 driver with little change as possible while introducing another d=
river.

So we change ksz_spi.c. Goal is to have clean code.

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--a1QUDc0q7S3U7/Jg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmzEdgACgkQMOfwapXb+vJzFQCeOz41QuTi6/A6kjn+6uVf9TUk
dBQAnjlKJqEEeRQ7RqW9edztNUlUbiVt
=BuE2
-----END PGP SIGNATURE-----

--a1QUDc0q7S3U7/Jg--
