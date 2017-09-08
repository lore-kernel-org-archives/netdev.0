From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 8 Sep 2017 23:57:35 +0200
Message-ID: <20170908215735.GF27428@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170908091856.GB17738@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="+ts6NCQ4mrNQIV8p"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+ts6NCQ4mrNQIV8p
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > > +	default:
> > > +		processed =3D false;
> > > +		break;
> > > +	}
> > > +	if (processed)
> > > +		*val =3D data;
> > > +}
> >=20
> > Similar code will be needed by other drivers, right?
>=20
> Although KSZ8795 and KSZ8895 may use the same code, the other
> chips will have different code.

Ok, please make sure code is shared between these two.

Thansk,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--+ts6NCQ4mrNQIV8p
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmzEk8ACgkQMOfwapXb+vJK1gCaAsS1MqB8PekZvB5z40FlFx30
1fcAoL6uUJ7qHdnUgdW9/VWb5a09VRh/
=kaeZ
-----END PGP SIGNATURE-----

--+ts6NCQ4mrNQIV8p--
