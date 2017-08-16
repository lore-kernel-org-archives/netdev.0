From: Pavel Machek <pavel@ucw.cz>
Subject: Re: DSA support for Micrel KSZ8895
Date: Wed, 16 Aug 2017 20:32:06 +0200
Message-ID: <20170816183205.GA11821@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="ReaqsoxgOBHFXBhH"
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com, Woojung.Huh@microchip.com
To: Andrew Lunn <andrew@lunn.ch>, nathan.leigh.conrad@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170816140451.GA13006@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > I've got hardware with KSZ8895, and I'd like to use switch ports as
> > separate ethernet cards. I believe that means DSA support.
> >=20
> > And there are even patches available from microchip... unfortunately
> > they are in strange form and for v3.18.
> >=20
> > http://www.microchip.com/SWLibraryWeb/product.aspx?product=3DKSZ8895%20=
Software%20Linux%203.18
> >=20
> > Is there newer version of the driver available somewhere? Is the
> > driver good starting point, or should I start with something else?
>=20
> Hi Pavel
>=20
> Woojung is the expert here. His DSA driver for the 9477 is a nice
> clean driver.

Good.

> Have you compared the 8895 to the 9477. Are they similar? Could the
> existing 9477 be extended to support the 8895?

Register layouts are completely different, at the very least. I'm not
sure if functionality maps 1:1, that was not exactly easy to check.

I've ported the v3.18 driver to v4.4; it looks like v4.5 port will not
be easy. Plus question is if it works at all... time will tell.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--ReaqsoxgOBHFXBhH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmUj6UACgkQMOfwapXb+vKLqACfeMUmsG6UBahvr5RE5kA4JQI9
KEQAniuWPSxnqXVv/VFNJOo4poFtbMTv
=v/vG
-----END PGP SIGNATURE-----

--ReaqsoxgOBHFXBhH--
