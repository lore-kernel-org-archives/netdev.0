From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v3 5/9] ARM: dts: sun8i-h3: add sun8i-emac ethernet driver
Date: Mon, 12 Sep 2016 09:29:33 +0200
Message-ID: <20160912072933.GC9449@lukather>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-6-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="TiqCXmo5T1hvSQQg"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473425117-18645-6-git-send-email-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--TiqCXmo5T1hvSQQg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 09, 2016 at 02:45:13PM +0200, Corentin Labbe wrote:
> The sun8i-emac is an ethernet MAC hardware that support 10/100/1000
> speed.
>=20
> This patch enable the sun8i-emac on the Allwinner H3 SoC Device-tree.
> The SoC H3 have an internal PHY, so optionals syscon and ephy are set.
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  arch/arm/boot/dts/sun8i-h3.dtsi | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
>=20
> diff --git a/arch/arm/boot/dts/sun8i-h3.dtsi b/arch/arm/boot/dts/sun8i-h3=
=2Edtsi
> index a39da6f..a3ac476 100644
> --- a/arch/arm/boot/dts/sun8i-h3.dtsi
> +++ b/arch/arm/boot/dts/sun8i-h3.dtsi
> @@ -50,6 +50,10 @@
>  / {
>  	interrupt-parent =3D <&gic>;
> =20
> +	aliases {
> +		ethernet0 =3D &emac;
> +	};
> +

This needs to be done at the board level.

>  	cpus {
>  		#address-cells =3D <1>;
>  		#size-cells =3D <0>;
> @@ -446,6 +450,21 @@
>  			status =3D "disabled";
>  		};
> =20
> +		emac: ethernet@1c30000 {
> +			compatible =3D "allwinner,sun8i-h3-emac";
> +			syscon =3D <&syscon>;
> +			reg =3D <0x01c30000 0x104>;
> +			reg-names =3D "emac";

You don't need reg-names anymore.

> +			interrupts =3D <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> +			resets =3D <&ccu RST_BUS_EMAC>, <&ccu RST_BUS_EPHY>;
> +			reset-names =3D "ahb", "ephy";
> +			clocks =3D <&ccu CLK_BUS_EMAC>, <&ccu CLK_BUS_EPHY>;
> +			clock-names =3D "ahb", "ephy";

I still believe that having the same node for both the PHY and the MAC
is wrong.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--TiqCXmo5T1hvSQQg
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX1lldAAoJEBx+YmzsjxAgGBYQAJQuZAU5uqV/AKLXyDlk/boP
uhLzc60KY3t7rCpEvkUGK0HwpcAM011+8jj4Q/4iVwLKS/RNXr42yI1yl1zQDLQm
jaot2HJ/LPU+e20297XtbhVidlCQ5lJxMcux47BI0QE+HPTPq8NvyWNrA1n9GB+d
PFnBnZ5WFW/GHDp2oSyoeMeUCyaEGUiT/lyOVwXJeh8rNDcW7oXApYoBYfY0z3vr
iqt3o+EPwIG2Gd0uTBkbtRNzJeP8FQLErWT4cs7UU9Mcf/s/OSLFDkXZIY7v5icf
SZJwtzFJpsa+utZMGEQpPM3z56qJQcnqKYXe9hzsMeYspIrcwYoxwm/WDSgQYu+U
acnB+S5bXZZutYcnuoMQztTXrho8P9pOtglHFWHK6dGouQuwZhc0LehHQIJNp9VB
buHGQpLOrCu8u4lgeqUeXOmOQCsya3Cb28KE1sxYL5Z7aT2XO46dsRTVIV9eI+pL
uTANw9JrhisLpX6IAThAvZIgzg4wNiRhfC3++WpLUtcMVt6CDL+2Vrt+87pogbAK
xQOYuGOkq8iquO/gsuA9CkH3ujlGjVNHdiE9jmpSbgAojDQzOtSF42os2pgALbUe
tj1X7Ti8GC9dXWeDXDWfSIerdplY80eLZoSDAlFbq4d7LdTnOnTUOVOrrJmzrC48
k1+s1/7NyBZ03CWaQR3U
=bScQ
-----END PGP SIGNATURE-----

--TiqCXmo5T1hvSQQg--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
