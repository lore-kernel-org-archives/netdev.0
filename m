From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
 drivers can be added
Date: Fri, 8 Sep 2017 23:53:36 +0200
Message-ID: <20170908215336.GD27428@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
 <20170907215417.GU11248@lunn.ch>
 <CAJGZr0+r3UhhRJcGXvBKZGamrSH_XEQY5oo7MTBjTTrDFOiKtg@mail.gmail.com>
 <20170908141225.GE25219@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E68@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="LKTjZJSUETSlgu2t"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121E68@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--LKTjZJSUETSlgu2t
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> There will be 5 drivers to support these devices:
>=20
> ksz9477.c - KSZ9893/KSZ9897/KSZ9567/KSZ9566/KSZ9477
> ksz8795.c - KSZ8795/KSZ8795/KSZ8765
> ksz8895.c - KSZ8895/KSZ8864

Could we see the 8895 driver, please?

> Out of topic I have a question to ask the community regarding the DSA
> port creation:
>=20
> Port 1 can be specified using the reg parameter specifying 0; port 2, 1;
> and so on.  The KSZ8794 is a variant of KSZ8795 with port 4 disabled.
> So
> lan1 =3D 0, lan2 =3D 1, lan3 =3D 2, cpu =3D 4.
> But our company Marketing does not want to promote that fact but treat
> KSZ8794 as a distinct product.
> So
> lan1 =3D 0, lan2 =3D 1, lan3 =3D 2, cpu =3D 3.
> Is this okay to hide this information inside the driver?  This is managea=
ble
> for KSZ8794 but for KSZ8864 the first port is disabled:
> lan1 =3D 1, lan2 =3D 2, lan3 =3D 3, cpu =3D 4.
>=20
> I am not sure whether DSA has or will have a way to display the port
> mapping to regular users.

Kernel is not a place to play marketing games, and people reading the
kernel sources are not targets of your marketing department.

Please let us just see the underlying hardware, as is.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--LKTjZJSUETSlgu2t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmzEWAACgkQMOfwapXb+vLySQCdG76V/sPDupe/caX/5Wk2hCgs
uHAAoILUi1Bgo7qZpv0jFxTVhK2GBbow
=fLsD
-----END PGP SIGNATURE-----

--LKTjZJSUETSlgu2t--
