From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Thu, 28 Sep 2017 17:24:45 +0200
Message-ID: <20170928152445.GC2482@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170908091856.GB17738@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
 <20170908215735.GF27428@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41123010@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="vOmOzSkFvhd7u8Ms"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41123010@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vOmOzSkFvhd7u8Ms
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> > > > Similar code will be needed by other drivers, right?
> > >
> > > Although KSZ8795 and KSZ8895 may use the same code, the other
> > > chips will have different code.
> >=20
> > Ok, please make sure code is shared between these two.
>=20
> The exact function probably cannot be shared between KSZ8795
> and KSZ8895 drivers because although the register constants look
> the same but their exact locations are different in the 2 chips.

Put the code into header as static inline and include it from both
places?

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--vOmOzSkFvhd7u8Ms
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnNFD0ACgkQMOfwapXb+vLQwgCgr6L1X8Awn3TZpBNxq7KF2fOM
FwEAnRzLr6C0SeRvCadgZzOgSSLM1v+G
=TX8o
-----END PGP SIGNATURE-----

--vOmOzSkFvhd7u8Ms--
