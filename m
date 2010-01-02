From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next 3/3] powerpc/mpc5xxx: add OF platform binding
	doc for FSL MSCAN devices
Date: Sat, 2 Jan 2010 15:05:23 +0100
Message-ID: <20100102140523.GD2239@pengutronix.de>
References: <1262420274-16586-1-git-send-email-wg@grandegger.com>
	<1262420274-16586-2-git-send-email-wg@grandegger.com>
	<1262420274-16586-3-git-send-email-wg@grandegger.com>
	<1262420274-16586-4-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2018842450=="
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1262420274-16586-4-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============2018842450==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+KJYzRxRHjYqLGl5"
Content-Disposition: inline


--+KJYzRxRHjYqLGl5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jan 02, 2010 at 09:17:54AM +0100, Wolfgang Grandegger wrote:
> From: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
>=20
> This patch adds documentation for the MSCAN OF device bindings for
> the MPC512x and moves the one for the MPC5200 to the new common file
> "Documentation/powerpc/dts-bindings/fsl/can.txt".
>=20
> Signed-off-by: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>

Looks good to me (except for the typos ;))

Acked-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

> ---
>  Documentation/powerpc/dts-bindings/fsl/can.txt     |   53 ++++++++++++++=
++++++
>  Documentation/powerpc/dts-bindings/fsl/mpc5200.txt |    9 +---
>  2 files changed, 54 insertions(+), 8 deletions(-)
>  create mode 100644 Documentation/powerpc/dts-bindings/fsl/can.txt
>=20
> diff --git a/Documentation/powerpc/dts-bindings/fsl/can.txt b/Documentati=
on/powerpc/dts-bindings/fsl/can.txt
> new file mode 100644
> index 0000000..44cfb61
> --- /dev/null
> +++ b/Documentation/powerpc/dts-bindings/fsl/can.txt
> @@ -0,0 +1,53 @@
> +CAN Device Tree Bindings
> +------------------------
> +
> +(c) 2006-2009 Secret Lab Technologies Ltd
> +Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> +
> +fsl,mpc5200-mscan nodes
> +-----------------------
> +In addition to the required compatible-, reg- and interrupt-properites, =
you can

properties.

> +also specify which clock source shall be used for the controller:
> +
> +- fsl,mscan-clock-source : a string describing the clock source. Valid v=
alues
> +			   are:	"ip" for ip bus clock
> +				 "ref" for reference clock (XTAL)
> +			   "ref" is default in case this property is not
> +			   present.
> +
> +fsl,mpc5121-mscan nodes
> +-----------------------
> +In addition to the required compatible-, reg- and interrupt-properites, =
you can

properties.

> +also specify which clock source shall be used for the controller:
> +
> +- fsl,mscan-clock-source : a string describing the clock source. Valid v=
alues
> +			   are:	"ip" for ip bus clock
> +				"ref" for reference clock
> +				"sys" for system clock
> +			   If this property is not present, an optimal CAN
> +			   clock source and frequency based on the system
> +			   will be selected. If this is not possible, the
> +			   reference clock will be used.
> +
> +- fsl,mscan-clock-divider: for the reference and system clock an additio=
nal
> +			   clock divider can be specified. By default a

I wonder if there should be a comma after 'default'. Maybe a native speaker=
 can
help?

> +			   value of 1 is used.
> +
> +Examples:
> +	can@1300 {
> +		compatible =3D "fsl,mpc5121-mscan";
> +		cell-index =3D <0>;
> +		interrupts =3D <12 0x8>;
> +		interrupt-parent =3D < &ipic >;
> +		reg =3D <0x1300 0x80>;
> +	};
> +
> +	can@1380 {
> +		compatible =3D "fsl,mpc5121-mscan";
> +		cell-index =3D <1>;
> +		interrupts =3D <13 0x8>;
> +		interrupt-parent =3D < &ipic >;
> +		reg =3D <0x1380 0x80>;
> +		fsl,mscan-clock-source =3D "ref";
> +		fsl,mscan-clock-divider =3D <3>;
> +	};
> diff --git a/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt b/Documen=
tation/powerpc/dts-bindings/fsl/mpc5200.txt
> index 5c6602d..4ccb2cd 100644
> --- a/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
> +++ b/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
> @@ -195,11 +195,4 @@ External interrupts:
> =20
>  fsl,mpc5200-mscan nodes
>  -----------------------
> -In addition to the required compatible-, reg- and interrupt-properites, =
you can
> -also specify which clock source shall be used for the controller:
> -
> -- fsl,mscan-clock-source- a string describing the clock source. Valid va=
lues
> -			  are:	"ip" for ip bus clock
> -				"ref" for reference clock (XTAL)
> -			  "ref" is default in case this property is not
> -			  present.
> +See file can.txt in this directory.
> --=20
> 1.6.2.5
>=20

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--+KJYzRxRHjYqLGl5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAks/UqMACgkQD27XaX1/VRs+yQCfewSViQxaNvPNF/wB3IZZtp0M
h94Anih0tjDpCYwEYgjnbFDIKdOYnwAj
=BIsB
-----END PGP SIGNATURE-----

--+KJYzRxRHjYqLGl5--

--===============2018842450==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============2018842450==--
