From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC] Add Microchip KSZ8895 DSA driver
Date: Sun, 22 Oct 2017 13:01:31 +0200
Message-ID: <20171022110130.GA2985@amd>
References: <1507322033-15222-1-git-send-email-Tristram.Ha@microchip.com>
 <1507322033-15222-2-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>, muvarov@gmail.com,
        nathan.leigh.conrad@gmail.com, vivien.didelot@savoirfairelinux.com,
        UNGLinuxDriver@microchip.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507322033-15222-2-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> diff --git a/drivers/net/dsa/microchip/Kconfig b/drivers/net/dsa/microchi=
p/Kconfig
> index cb95d3d..b854c4b 100644
> --- a/drivers/net/dsa/microchip/Kconfig
> +++ b/drivers/net/dsa/microchip/Kconfig
> @@ -27,3 +27,20 @@ config MICROCHIP_KSZ8795_SPI_DRIVER
> =20
>  	  It is required to use the KSZ8795 switch driver as the only access
>  	  is through SPI.
> +
> +menuconfig MICROCHIP_KSZ8895
> +	tristate "Microchip KSZ8895 series switch support"
> +	depends on NET_DSA
> +	select NET_DSA_TAG_KSZ8795

Aha. So this depends not only on "preparation" series, but also on
8795 driver. Surprise!

If you had a git tree with series applied, that would be nice.

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnseooACgkQMOfwapXb+vI2tgCcDJ6kUfarqzdn82u8th3fbk1G
EYYAni87LSFIBG+DBqZ2GfGv8eL4pyEn
=ZJRa
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
