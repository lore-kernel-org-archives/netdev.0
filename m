From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 5/5] Add KSZ8795 SPI driver
Date: Fri, 8 Sep 2017 11:26:14 +0200
Message-ID: <20170908092614.GB18365@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A95@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7iMSBzlTiPOCCT2k"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:34437 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752074AbdIHJ0X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 05:26:23 -0400
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A95@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7iMSBzlTiPOCCT2k
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!


> +static int ksz_spi_read(struct ksz_device *dev, u32 reg, u8 *data,
> +			unsigned int len)
> +{
> +	struct spi_device *spi =3D dev->priv;
> +
> +	return ksz_spi_read_reg(spi, reg, data, len); }
> +
> +static int ksz_spi_read8(struct ksz_device *dev, u32 reg, u8 *val) {
> +	return ksz_spi_read(dev, reg, val, 1); }
> +
> +static int ksz_spi_read16(struct ksz_device *dev, u32 reg, u16 *val) {
> +	int ret =3D ksz_spi_read(dev, reg, (u8 *)val, 2);
> +
> +	if (!ret)
> +		*val =3D be16_to_cpu(*val);
> +
> +	return ret;
> +}

> +static int ksz_spi_read32(struct ksz_device *dev, u32 reg, u32 *val) {
> +	int ret =3D ksz_spi_read(dev, reg, (u8 *)val, 4);
> +
> +	if (!ret)
> +		*val =3D be32_to_cpu(*val);
> +
> +	return ret;
> +}

Please format according to CodingStyle. (Not only this.)

And this will be common for more drivers. Can it go to a header file
and be included...?


									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--7iMSBzlTiPOCCT2k
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmyYjYACgkQMOfwapXb+vLQHACggMi5qp8GC4fvQl7MLsrtXfyO
kwUAn33zfxGvHasm7e0cSJoPzNwmfE5t
=O0sP
-----END PGP SIGNATURE-----

--7iMSBzlTiPOCCT2k--
