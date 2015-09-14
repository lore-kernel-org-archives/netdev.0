From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v6 1/3] can: Allwinner A10/A20 CAN Controller support -
 Devicetree bindings
Date: Mon, 14 Sep 2015 14:58:21 +0200
Message-ID: <55F6C46D.7090203@pengutronix.de>
References: <1442235299-5885-1-git-send-email-info@gerhard-bertelsmann.de>
 <1442235299-5885-2-git-send-email-info@gerhard-bertelsmann.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="L9EJcg0wTGHoKgxVOcplLhfqBpFq5MhiU"
To: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>,
	wg@grandegger.com, maxime.ripard@free-electrons.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1442235299-5885-2-git-send-email-info@gerhard-bertelsmann.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--L9EJcg0wTGHoKgxVOcplLhfqBpFq5MhiU
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 09/14/2015 02:54 PM, Gerhard Bertelsmann wrote:
> Signed-off-by: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
> ---
>=20
>  .../devicetree/bindings/net/can/sun4i_can.txt      |  37 +
>  1 files changed, 37 insertions(+)
>=20
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/sun4i_can.txt b/=
Documentation/devicetree/bindings/net/can/sun4i_can.txt
> new file mode 100644
> index 0000000..b572e2b
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/sun4i_can.txt
> @@ -0,0 +1,37 @@
> +Allwinner A10/A20 CAN controller Device Tree Bindings
> +-----------------------------------------------------
> +
> +Required properties:
> +- compatible: "allwinner,sunxican"
> +- reg: physical base address and size of the Allwinner A10/A20 CAN reg=
ister map.
> +- interrupts: interrupt specifier for the sole interrupt.
> +- clock: phandle and clock specifier.
> +
> +Example
> +-------
> +
> +SoC common .dtsi file:
> +
> +	can0_pins_a: can0 <at> 0 {

That's supposed to be a proper "@":

    can0@0

> +		allwinner,pins =3D "PH20","PH21";
> +		allwinner,function =3D "can";
> +		allwinner,drive =3D <0>;
> +		allwinner,pull =3D <0>;
> +	};
> +
> +	can0: can <at> 01c2bc00 {

    can0@01c2bc00

> +		compatible =3D "allwinner,sunxican";
> +		reg =3D <0x01c2bc00 0x400>;
> +		interrupts =3D <0 26 4>;
> +		clocks =3D <&apb1_gates 4>;
> +		status =3D "disabled";
> +	};
> +
> +Board specific .dts file:
> +
> +	can0: can <at> 01c2bc00 {

can0@01c2bc00

> +		pinctrl-names =3D "default";
> +		pinctrl-0 =3D <&can0_pins_a>;
> +		status =3D "okay";
> +	};
> +
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--L9EJcg0wTGHoKgxVOcplLhfqBpFq5MhiU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJV9sRtAAoJEP5prqPJtc/HfLYIAJtqYMtePOE9hD6Il60R9Uxr
T/BSdHQKv6g1++Hg2JKkGX+aBm+ZDEC2OYUX1eXKyBI7YoKspzY86P6oL8nLnhh8
vMs5pN1U4KRnE9YsUEgBV2q06NVrWPVIdR3mUHXhwyF7gfDk1Hx5zOnIFmCLc96F
besFlyTdGh1LijNt/GWktjsFcN7+LEA1GuKChuYT5nw+iw9ljentiNkwjYlVQT2v
oprcJuim31J+qgO5wQgLnA4gE63PtDbxT1bwQM3PRL/RkBpl5GnCCer2wU1kInEh
wN8p2WJ6Z36sXHyD1Q3ZijmcYoBWJ29wK81mPpGodm2jipuja2WDKITs5UxpO20=
=yLEO
-----END PGP SIGNATURE-----

--L9EJcg0wTGHoKgxVOcplLhfqBpFq5MhiU--
