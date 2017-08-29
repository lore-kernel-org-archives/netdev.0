From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Tue, 29 Aug 2017 09:41:30 +0200
Message-ID: <20170829074130.GA31303@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd>
 <20170828140927.GD10418@lunn.ch>
 <CAJGZr0K46jBd9Sn4HNPgAeHTQtBuBHzX87GveAJf3_5b_WM69g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="vkogqOf2sHV7VnPd"
Cc: Andrew Lunn <andrew@lunn.ch>, Woojung.Huh@microchip.com,
        nathan.leigh.conrad@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Maxim Uvarov <muvarov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJGZr0K46jBd9Sn4HNPgAeHTQtBuBHzX87GveAJf3_5b_WM69g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> Micrel has some drivers on their web site to support some chips. For
> that chips they do virtual mdio over spi.
> And driver is available on download page:
> http://www.microchip.com/wwwproducts/en/KSZ8895
>=20
> Documentation->Software library.
>=20
> Both driver and DSA driver. Driver has to work with some minor fixups
> related to your kernel version. But I think they are don't care about
> up-streaming that code.
> So you can take their code as a reference.

"Minor fixups". Take a look at the driver.. I wanted to do a "minor
fixups". It turned out it was easier to start from scratch.

But the MDIO emaulation code is from their driver, after lots of
deletions.

								Pavel
							=09
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--vkogqOf2sHV7VnPd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmlGqoACgkQMOfwapXb+vJ2BACgs1qeL/zY84WSsW+qqDcdgknG
0MoAmgJnqzHDf1r8n5OOQfvuvkSicDcd
=iz+a
-----END PGP SIGNATURE-----

--vkogqOf2sHV7VnPd--
