From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 1/6] The file ksz_common.c will be used by other KSZ
 switch drivers.
Date: Fri, 8 Sep 2017 10:56:50 +0200
Message-ID: <20170908085650.GC16834@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218C4@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD411219FF@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="zCKi3GIZzVBPywwA"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD411219FF@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--zCKi3GIZzVBPywwA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2017-09-07 21:08:58, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
>=20
> Break ksz_common.c into 2 files so that the common code can be used by ot=
her KSZ switch drivers.
>=20
> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> ---
> diff --git a/drivers/net/dsa/microchip/Makefile b/drivers/net/dsa/microch=
ip/Makefile
> index ed335e2..0961c30 100644
> --- a/drivers/net/dsa/microchip/Makefile
> +++ b/drivers/net/dsa/microchip/Makefile
> @@ -1,2 +1,2 @@
> -obj-$(CONFIG_MICROCHIP_KSZ)	        +=3D ksz_common.o
> +obj-$(CONFIG_MICROCHIP_KSZ)	        +=3D ksz9477.o ksz_common.o
>  obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+=3D ksz_spi.o

I believe you should also rename option to CONFIG_MICROCHIP_KSZ_9477
here... and introduce appropriate Kconfig change.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--zCKi3GIZzVBPywwA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmyW1IACgkQMOfwapXb+vKtxwCcDY6e1yVa4iZ1ZDUdGujePyGW
WIEAnReqkGWm7kB0e+nhlWW3wdU6lCVA
=xBp2
-----END PGP SIGNATURE-----

--zCKi3GIZzVBPywwA--
