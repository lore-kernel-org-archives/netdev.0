From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Tue, 29 Aug 2017 23:15:19 +0200
Message-ID: <20170829211519.GA24221@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd>
 <20170828140927.GD10418@lunn.ch>
 <CAJGZr0K46jBd9Sn4HNPgAeHTQtBuBHzX87GveAJf3_5b_WM69g@mail.gmail.com>
 <20170829074130.GA31303@amd>
 <20170829122604.GA22093@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="ReaqsoxgOBHFXBhH"
Cc: Maxim Uvarov <muvarov@gmail.com>, Woojung.Huh@microchip.com,
        nathan.leigh.conrad@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170829122604.GA22093@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue 2017-08-29 14:26:04, Andrew Lunn wrote:
> > But the MDIO emaulation code is from their driver, after lots of
> > deletions.
>=20
> Is this driver supposed to run on lots of different OSs? That would
> explain why they ignored the Linux MDIO and PHY layers.

It did not look particulary portable.

> If possible, please make use of the Linux infrastructure.

I did not find any infrastructure I could use instead
ksz_mdio_emulation.

Now, drivers/net/phy/spi_ks8995.c can access the PHY registers, and I
can not see any translation there, so there may be something I'm
missing.

Pointers would be welcome at this point.

Thanks,
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

iEYEARECAAYFAlml2WcACgkQMOfwapXb+vLVwwCeNxaoqTnYD9P+yr0n02pguWma
+R4AoJCrQwv5a0j15654Gwra85sCjnFX
=cpiH
-----END PGP SIGNATURE-----

--ReaqsoxgOBHFXBhH--
