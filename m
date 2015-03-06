From: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 2/3] ARM: at91/dt: fix macb compatible strings
Date: Fri, 6 Mar 2015 17:45:15 +0100
Message-ID: <54F9D99B.3090006@atmel.com>
References: <1425637442-8724-1-git-send-email-boris.brezillon@free-electrons.com> <1425637442-8724-3-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	"Alexandre Belloni" <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	"Kumar Gala" <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425637442-8724-3-git-send-email-boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 06/03/2015 11:24, Boris Brezillon a =E9crit :
> Some at91 SoCs embed a 10/100 Mbit Ethernet IP, that is based on the
> at91sam9260 SoC.
> Fix at91 DTs accordingly.
>=20
> Signed-off-by: Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> Reviewed-by: Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Acked-by: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
> ---
>  arch/arm/boot/dts/at91sam9260.dtsi      | 2 +-
>  arch/arm/boot/dts/at91sam9263.dtsi      | 2 +-
>  arch/arm/boot/dts/at91sam9g45.dtsi      | 2 +-
>  arch/arm/boot/dts/at91sam9x5_macb0.dtsi | 2 +-
>  arch/arm/boot/dts/at91sam9x5_macb1.dtsi | 2 +-
>  arch/arm/boot/dts/sama5d3_emac.dtsi     | 2 +-
>  6 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/arch/arm/boot/dts/at91sam9260.dtsi b/arch/arm/boot/dts/a=
t91sam9260.dtsi
> index fff0ee6..9f7c737 100644
> --- a/arch/arm/boot/dts/at91sam9260.dtsi
> +++ b/arch/arm/boot/dts/at91sam9260.dtsi
> @@ -842,7 +842,7 @@
>  			};
> =20
>  			macb0: ethernet@fffc4000 {
> -				compatible =3D "cdns,at32ap7000-macb", "cdns,macb";
> +				compatible =3D "cdns,at91sam9260-macb", "cdns,macb";
>  				reg =3D <0xfffc4000 0x100>;
>  				interrupts =3D <21 IRQ_TYPE_LEVEL_HIGH 3>;
>  				pinctrl-names =3D "default";
> diff --git a/arch/arm/boot/dts/at91sam9263.dtsi b/arch/arm/boot/dts/a=
t91sam9263.dtsi
> index 1f67bb4..340179e 100644
> --- a/arch/arm/boot/dts/at91sam9263.dtsi
> +++ b/arch/arm/boot/dts/at91sam9263.dtsi
> @@ -845,7 +845,7 @@
>  			};
> =20
>  			macb0: ethernet@fffbc000 {
> -				compatible =3D "cdns,at32ap7000-macb", "cdns,macb";
> +				compatible =3D "cdns,at91sam9260-macb", "cdns,macb";
>  				reg =3D <0xfffbc000 0x100>;
>  				interrupts =3D <21 IRQ_TYPE_LEVEL_HIGH 3>;
>  				pinctrl-names =3D "default";
> diff --git a/arch/arm/boot/dts/at91sam9g45.dtsi b/arch/arm/boot/dts/a=
t91sam9g45.dtsi
> index ee80aa9..586eab7 100644
> --- a/arch/arm/boot/dts/at91sam9g45.dtsi
> +++ b/arch/arm/boot/dts/at91sam9g45.dtsi
> @@ -956,7 +956,7 @@
>  			};
> =20
>  			macb0: ethernet@fffbc000 {
> -				compatible =3D "cdns,at32ap7000-macb", "cdns,macb";
> +				compatible =3D "cdns,at91sam9260-macb", "cdns,macb";
>  				reg =3D <0xfffbc000 0x100>;
>  				interrupts =3D <25 IRQ_TYPE_LEVEL_HIGH 3>;
>  				pinctrl-names =3D "default";
> diff --git a/arch/arm/boot/dts/at91sam9x5_macb0.dtsi b/arch/arm/boot/=
dts/at91sam9x5_macb0.dtsi
> index 57e89d1..73d7e30 100644
> --- a/arch/arm/boot/dts/at91sam9x5_macb0.dtsi
> +++ b/arch/arm/boot/dts/at91sam9x5_macb0.dtsi
> @@ -53,7 +53,7 @@
>  			};
> =20
>  			macb0: ethernet@f802c000 {
> -				compatible =3D "cdns,at32ap7000-macb", "cdns,macb";
> +				compatible =3D "cdns,at91sam9260-macb", "cdns,macb";
>  				reg =3D <0xf802c000 0x100>;
>  				interrupts =3D <24 IRQ_TYPE_LEVEL_HIGH 3>;
>  				pinctrl-names =3D "default";
> diff --git a/arch/arm/boot/dts/at91sam9x5_macb1.dtsi b/arch/arm/boot/=
dts/at91sam9x5_macb1.dtsi
> index 663676c..d81980c 100644
> --- a/arch/arm/boot/dts/at91sam9x5_macb1.dtsi
> +++ b/arch/arm/boot/dts/at91sam9x5_macb1.dtsi
> @@ -41,7 +41,7 @@
>  			};
> =20
>  			macb1: ethernet@f8030000 {
> -				compatible =3D "cdns,at32ap7000-macb", "cdns,macb";
> +				compatible =3D "cdns,at91sam9260-macb", "cdns,macb";
>  				reg =3D <0xf8030000 0x100>;
>  				interrupts =3D <27 IRQ_TYPE_LEVEL_HIGH 3>;
>  				pinctrl-names =3D "default";
> diff --git a/arch/arm/boot/dts/sama5d3_emac.dtsi b/arch/arm/boot/dts/=
sama5d3_emac.dtsi
> index fe2af92..b4544cf 100644
> --- a/arch/arm/boot/dts/sama5d3_emac.dtsi
> +++ b/arch/arm/boot/dts/sama5d3_emac.dtsi
> @@ -41,7 +41,7 @@
>  			};
> =20
>  			macb1: ethernet@f802c000 {
> -				compatible =3D "cdns,at32ap7000-macb", "cdns,macb";
> +				compatible =3D "cdns,at91sam9260-macb", "cdns,macb";
>  				reg =3D <0xf802c000 0x100>;
>  				interrupts =3D <35 IRQ_TYPE_LEVEL_HIGH 3>;
>  				pinctrl-names =3D "default";
>=20


--=20
Nicolas Ferre
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
