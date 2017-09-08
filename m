From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
 drivers can be added
Date: Fri, 8 Sep 2017 23:50:43 +0200
Message-ID: <20170908215042.GC27428@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
 <20170907215417.GU11248@lunn.ch>
 <CAJGZr0+r3UhhRJcGXvBKZGamrSH_XEQY5oo7MTBjTTrDFOiKtg@mail.gmail.com>
 <20170908141225.GE25219@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E68@CHN-SV-EXMX02.mchp-main.com>
 <20170908190122.GM25219@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="MnLPg7ZWsaic7Fhd"
Cc: Tristram.Ha@microchip.com, muvarov@gmail.com,
        nathan.leigh.conrad@gmail.com, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Woojung.Huh@microchip.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170908190122.GM25219@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--MnLPg7ZWsaic7Fhd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2017-09-08 21:01:22, Andrew Lunn wrote:
> > > So i would suggest one driver supporting all the different devices.
> >=20
> > There will be 5 drivers to support these devices:
> >=20
> > ksz9477.c - KSZ9893/KSZ9897/KSZ9567/KSZ9566/KSZ9477
> > ksz8795.c - KSZ8795/KSZ8795/KSZ8765
> > ksz8895.c - KSZ8895/KSZ8864
> > ksz8863.c - KSZ8863/KSZ8873
> > ksz8463.c - KSZ8463
> >=20
> > These chips have different SPI access mechanisms, MIB counter reading,
> > and register set.  These can be combined into one single driver using
> > function pointers, at least for ksz8795/ksz8895/ksz8863/ksz8463.  My
> > only concern is the memory footprint.  The customer may not want a
> > big driver to cover all the switches while only one is used.
>=20
> If memory footprint is your problem, make it a compile time choice
> which devices are supported within the one driver. In practice, you
> will find most distributions just enable them all.

I have to side with Tristram here. The register layouts are so
different that single driver does not make sense.

What could make sense is single function, compiled 5 times, based on
different includes; same source code but 5 different binaries.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--MnLPg7ZWsaic7Fhd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmzELIACgkQMOfwapXb+vL21ACgwCKR+IXeFNHNqCHbqpb2z3mC
GL4AnirFXY0nE2dwvbBuSju8ld5UTfKQ
=fwvu
-----END PGP SIGNATURE-----

--MnLPg7ZWsaic7Fhd--
