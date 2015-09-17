From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v8 1/3] can: Allwinner A10/A20 CAN Controller support -
 Devicetree bindings
Date: Thu, 17 Sep 2015 10:04:56 +0200
Message-ID: <55FA7428.4030801@pengutronix.de>
References: <1442402482-7118-1-git-send-email-info@gerhard-bertelsmann.de>
 <1442402482-7118-2-git-send-email-info@gerhard-bertelsmann.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="DnEEud09CUixDbdGAbIXlsqhF8WhuhQ60"
To: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>,
	wg@grandegger.com, maxime.ripard@free-electrons.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442402482-7118-2-git-send-email-info@gerhard-bertelsmann.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DnEEud09CUixDbdGAbIXlsqhF8WhuhQ60
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 09/16/2015 01:21 PM, Gerhard Bertelsmann wrote:
> Devicetree bindings for Allwinner A10/A20 CAN
>=20
> Signed-off-by: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
> ---
>=20
>  .../devicetree/bindings/net/can/sun4i_can.txt      |  38 +
>  1 files changed, 389 insertions(+)
>=20
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/sun4i_can.txt b/=
Documentation/devicetree/bindings/net/can/sun4i_can.txt
> new file mode 100644
> index 0000000..cd0f50c
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/sun4i_can.txt
> @@ -0,0 +1,38 @@
> +Allwinner A10/A20 CAN controller Device Tree Bindings
> +-----------------------------------------------------
> +
> +Required properties:
> +- compatible: "allwinner,sun4i-a10-can"
> +- reg: physical base address and size of the Allwinner A10/A20 CAN reg=
ister map.
> +- interrupts: interrupt specifier for the sole interrupt.
> +- clock: phandle and clock specifier.
> +
> +
> +Example
> +-------
> +
> +SoC common .dtsi file:
> +
> +	can0_pins_a: can0@0 {
> +		allwinner,pins =3D "PH20","PH21";
> +		allwinner,function =3D "can";
> +		allwinner,drive =3D <0>;
> +		allwinner,pull =3D <0>;
> +	};
> +...
> +	can0: can@01c2bc00 {
> +		compatible =3D "allwinner,sun4i-a10-can";
> +		reg =3D <0x01c2bc00 0x400>;
> +		interrupts =3D <0 26 4>;
> +		clocks =3D <&apb1_gates 4>;
> +		status =3D "disabled";
> +	};

What about adding this snippet to SoC where the CAN core is available?
Maxime, what's the policy on sinxi? If you give me an Ack I'd like to
take the series via linux-can-next (and to net-next) upstream.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--DnEEud09CUixDbdGAbIXlsqhF8WhuhQ60
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJV+nQoAAoJEP5prqPJtc/HGtoIAJRGX/E7oo+0++CedkT1OYMx
b6yT4mpAwfLOqcWFQJoNfEQNUcudbHQswBkfFnIKaRFp1HxHnXndqD9zSrDS3gK3
ZbYh8F37oxi4Tv9qJaN4/nvEG92g2HdRFCuhvisGJhrCTZCnhZE1Fy3BEy9wfvw/
s/3YhrLrXNnbsIc7MfgL7oeS5bkQJTmZV3oxFJb3yEmhl9DKUQJPg3IcGQVzr7Gv
SEaFWtOtJW8kXhXVlei5SOcFseEMw60KjFehOEg3KZ55ValmKuWrn21Kj5T5wIJY
Y3MTnSuVyNJAy8CeRpI0VeKQylxgM6dEZmX+0u4+GmMIATtG6vpiUj2nLpgjcJE=
=7blM
-----END PGP SIGNATURE-----

--DnEEud09CUixDbdGAbIXlsqhF8WhuhQ60--
