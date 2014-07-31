From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 1/2] rcar_can: document device tree bindings
Date: Thu, 31 Jul 2014 23:31:59 +0200
Message-ID: <53DAB5CF.8000407@pengutronix.de>
References: <201408010124.26505.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="FsXowED51Aco8VL12W78o92IgaqntontE"
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org,
	vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	devicetree@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201408010124.26505.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FsXowED51Aco8VL12W78o92IgaqntontE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/31/2014 11:24 PM, Sergei Shtylyov wrote:
> Document the R-Car CAN device tree bindings.
>=20
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

The series looks good from the CAN perpective. I'll apply the patches
after we've got an Acked-by from the DT folks.

Marc

>=20
> ---
> The patch is against the 'linux-can-next.git' repo.
>=20
> Changes in version 2:
> - new patch, split from the driver's device tree support patch;
> - adjusted "clocks" property to refer to 3 clocks instead of 1;
> - added mandatory "clock-names" property;
> - renamed the "clock-select" property to "renesas,can-clock-select".
>=20
>  Documentation/devicetree/bindings/net/can/rcar_can.txt |   43 ++++++++=
+++++++++
>  1 file changed, 43 insertions(+)
>=20
> Index: linux-can-next/Documentation/devicetree/bindings/net/can/rcar_ca=
n.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- /dev/null
> +++ linux-can-next/Documentation/devicetree/bindings/net/can/rcar_can.t=
xt
> @@ -0,0 +1,43 @@
> +Renesas R-Car CAN controller Device Tree Bindings
> +-------------------------------------------------
> +
> +Required properties:
> +- compatible: "renesas,can-r8a7778" if CAN controller is a part of R8A=
7778 SoC.
> +	      "renesas,can-r8a7779" if CAN controller is a part of R8A7779 So=
C.
> +	      "renesas,can-r8a7790" if CAN controller is a part of R8A7790 So=
C.
> +	      "renesas,can-r8a7791" if CAN controller is a part of R8A7791 So=
C.
> +- reg: physical base address and size of the R-Car CAN register map.
> +- interrupts: interrupt specifier for the sole interrupt.
> +- clocks: phandles and clock specifiers for 3 CAN clock inputs.
> +- clock-names: 3 clock input name strings: "clkp1", "clkp2", "can_clk"=
=2E
> +- pinctrl-0: pin control group to be used for this controller.
> +- pinctrl-names: must be "default".
> +
> +Optional properties:
> +- renesas,can-clock-select: R-Car CAN Clock Source Select. Valid value=
s are:
> +			    <0x0> (default) : Peripheral clock (clkp1)
> +			    <0x1> : Peripheral clock (clkp2)
> +			    <0x3> : Externally input clock
> +
> +Example
> +-------
> +
> +SoC common .dtsi file:
> +
> +	can0: can@e6e80000 {
> +		compatible =3D "renesas,can-r8a7791";
> +		reg =3D <0 0xe6e80000 0 0x1000>;
> +		interrupts =3D <0 186 IRQ_TYPE_LEVEL_HIGH>;
> +		clocks =3D <&mstp9_clks R8A7791_CLK_RCAN0>,
> +		       	 <&cpg_clocks R8A7791_CLK_RCAN>, <&can_clk>;
> +		clock-names =3D "clkp1", "clkp2", "can_clk";
> +		status =3D "disabled";
> +	};
> +
> +Board specific .dts file:
> +
> +&can0 {
> +	pinctrl-0 =3D <&can0_pins>;
> +	pinctrl-names =3D "default";
> +	status =3D "okay";
> +};
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--FsXowED51Aco8VL12W78o92IgaqntontE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlPatc8ACgkQjTAFq1RaXHOcowCgl/LMlK7JEu0EsxGWyxQ6X6nQ
GcQAnRa1j7v8IAd0fiBZeQkuGHVht3H9
=9LoU
-----END PGP SIGNATURE-----

--FsXowED51Aco8VL12W78o92IgaqntontE--
