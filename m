From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 7/8] net: can: c_can: Add support for TI DRA7 DCAN
Date: Fri, 14 Nov 2014 16:56:37 +0100
Message-ID: <54662635.5020101@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-8-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="1MFWPXKcR9NKi3Bl5PnMRLfu2fgOgcEIw"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415371762-29885-8-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1MFWPXKcR9NKi3Bl5PnMRLfu2fgOgcEIw
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/07/2014 03:49 PM, Roger Quadros wrote:
> DRA7 SoC has 2 CAN IPs. Provide compatible IDs and RAMINIT
> register data for both.
>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>  Documentation/devicetree/bindings/net/can/c_can.txt |  1 +
>  drivers/net/can/c_can/c_can_platform.c              | 11 +++++++++++
>  2 files changed, 12 insertions(+)
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Docu=
mentation/devicetree/bindings/net/can/c_can.txt
> index a3ca3ee..f682fdb 100644
> --- a/Documentation/devicetree/bindings/net/can/c_can.txt
> +++ b/Documentation/devicetree/bindings/net/can/c_can.txt
> @@ -4,6 +4,7 @@ Bosch C_CAN/D_CAN controller Device Tree Bindings
>  Required properties:
>  - compatible		: Should be "bosch,c_can" for C_CAN controllers and
>  			  "bosch,d_can" for D_CAN controllers.
> +			  Can be "ti,dra7-d_can".
>  - reg			: physical base address and size of the C_CAN/D_CAN
>  			  registers map
>  - interrupts		: property with a value describing the interrupt
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c=
_can/c_can_platform.c
> index 71b9063..7a81db4 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -195,6 +195,16 @@ static struct c_can_driver_data d_can_drvdata =3D =
{
>  	.id =3D BOSCH_D_CAN,
>  };
> =20
> +static u8 dra7_raminit_start_bits[] =3D {3, 5};
> +static u8 dra7_raminit_done_bits[] =3D {1, 2};
> +static struct c_can_driver_data dra7_dcan_drvdata =3D {
> +	.id =3D BOSCH_D_CAN,
> +	.num_can =3D 2,
                   ^
Replaced by ARRAY_SIZE(dra7_raminit_start_bits)

Same for the am3352_dcan_drvdata in the next patch.

> +	.raminit_start_bits =3D dra7_raminit_start_bits,
> +	.raminit_done_bits =3D dra7_raminit_done_bits,
> +	.raminit_pulse =3D true,
> +};

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--1MFWPXKcR9NKi3Bl5PnMRLfu2fgOgcEIw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZiY1AAoJECte4hHFiupUDdkP/3lVqjNHs2cnWCL/GcRJubGL
V7g8CN5I+2SN6jjWP5lyCf5mpsKEtIls+C+ybJy2EYJETEnYfC8zzOkp5Jux+3wV
0YlehijuixVKlqFRcTi6TAc3omBUOIGhNQsL2Nwwkcu8FX1DBOdG3C3jxZRaucIj
6vfitct7gZY5nN3l7dApXD6rVVPbWznKByS432DlfJs2JVvL2LtRnJ/keY5vvEp2
uzxEf2wbhQGkg4xjQdfVYfSkIbP/Ej8g6wgNoYiMsEWkFYdHTLOTgoyJzSMn5PGR
pjKe4cj1lfcH8/MMTSX81b1Iqa46NxVlY9UeE3nHAb/aCl5RvGXzQCC0CCzK3zBn
z6CKypUWsdjLJg978PPiwbYDOpjuxNp84tpHMd6jWFBni5TNNK4BjCd9dApCF4XR
fi69TH9UbF68olGepqzOmO0r3RDfGIseUF5430mZ9R5BN9S4bngq1B767zOVYr31
jMP76yHA6qNRnptDjCF5s+9DyisOqRD5o1gIvtTI80TwVEdZ9HFD+ysuzG05r0Jl
5jWrBL8yUwnB2X3zTcYrVAxcVQ1hokvYcS5yW4mZiLhBHq4PEpNq/PUG+38W/VHY
XV+EWCnBFG+7AxLnGN871VxO9muD/mSdScN6pHI4d6YO0Cn/T++ClFn+aiKBp0Rp
/crfguAKhA1qyVnTZ8Ky
=QhBU
-----END PGP SIGNATURE-----

--1MFWPXKcR9NKi3Bl5PnMRLfu2fgOgcEIw--
