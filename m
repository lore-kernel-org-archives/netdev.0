From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Tue, 29 Aug 2017 09:45:47 +0200
Message-ID: <20170829074547.GB31303@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd>
 <20170828140927.GD10418@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="lEGEL1/lMxI0MVQ2"
Cc: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828140927.GD10418@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--lEGEL1/lMxI0MVQ2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2017-08-28 16:09:27, Andrew Lunn wrote:
> > I may be confused here, but AFAICT:
> >=20
> > 1) Yes, it has standard layout when accessed over MDIO.=20
>=20
>=20
> Section 4.8 of the datasheet says:
>=20
> 	All the registers defined in this section can be also accessed
> 	via the SPI interface.
>=20
> Meaning all PHY registers can be access via the SPI interface. So you
> should be able to make a standard Linux MDIO bus driver which performs
> SPI reads.

As far as I can tell (and their driver confirms) -- yes, all those
registers can be accessed over the SPI, they are just shuffled
around... hence MDIO emulation code. I copied it from their code (see
the copyrights) so no, I don't believe there's nicer solution.

Best regards,

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--lEGEL1/lMxI0MVQ2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmlG6sACgkQMOfwapXb+vK4oQCgwPtddQoQkMpdpjc7JWEpBjSI
9RUAoKbltoD4AwyMB/Q/EjeVdAC3AXSA
=+nS1
-----END PGP SIGNATURE-----

--lEGEL1/lMxI0MVQ2--
