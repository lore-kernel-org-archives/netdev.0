From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: EG20T PCH: use BIT(X)
Date: Wed, 17 Nov 2010 14:04:21 +0100
Message-ID: <4CE3D2D5.3030301@pengutronix.de>
References: <4CE3C90D.6010705@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1329706560981547680=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CE3C90D.6010705-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============1329706560981547680==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD78484C5CF4FA3153FBA1420"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD78484C5CF4FA3153FBA1420
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/17/2010 01:22 PM, Tomoya MORINAGA wrote:
> Replace bit assignment value to BIT(X).
> For easy to readable/identifiable, replace all bit assigned macros to B=
IT(X)
>=20
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>

IMHO you can squash this into the "add  prefix to macro" patch.
You have my Acked-by for both solutions.

cheers, Marc

> ---
>  drivers/net/can/pch_can.c |   73 +++++++++++++++++++++++--------------=
--------
>  1 files changed, 37 insertions(+), 36 deletions(-)
>=20
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index c523e3d..238622a 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -38,50 +38,51 @@
> =20
>  #define PCH_ENABLE		1 /* The enable flag */
>  #define PCH_DISABLE		0 /* The disable flag */
> -#define PCH_CTRL_INIT		0x0001 /* The INIT bit of CANCONT register. */
> -#define PCH_CTRL_IE		0x0002 /* The IE bit of CAN control register */
> -#define PCH_CTRL_IE_SIE_EIE	0x000e
> -#define PCH_CTRL_CCE		0x0040
> -#define PCH_CTRL_OPT		0x0080 /* The OPT bit of CANCONT register. */
> -#define PCH_OPT_SILENT		0x0008 /* The Silent bit of CANOPT reg. */
> -#define PCH_OPT_LBACK		0x0010 /* The LoopBack bit of CANOPT reg. */
> +#define PCH_CTRL_INIT		BIT(0) /* The INIT bit of CANCONT register. */
> +#define PCH_CTRL_IE		BIT(1) /* The IE bit of CAN control register */
> +#define PCH_CTRL_IE_SIE_EIE	(BIT(3) | BIT(2) | BIT(1))
> +#define PCH_CTRL_CCE		BIT(6)
> +#define PCH_CTRL_OPT		BIT(7) /* The OPT bit of CANCONT register. */
> +#define PCH_OPT_SILENT		BIT(3) /* The Silent bit of CANOPT reg. */
> +#define PCH_OPT_LBACK		BIT(4) /* The LoopBack bit of CANOPT reg. */
> +
>  #define PCH_CMASK_RX_TX_SET	0x00f3
>  #define PCH_CMASK_RX_TX_GET	0x0073
>  #define PCH_CMASK_ALL		0xff
> -#define PCH_CMASK_RDWR		0x80
> -#define PCH_CMASK_ARB		0x20
> -#define PCH_CMASK_CTRL		0x10
> -#define PCH_CMASK_MASK		0x40
> -#define PCH_CMASK_NEWDAT	0x04
> -#define PCH_CMASK_CLRINTPND	0x08
> -#define PCH_IF_MCONT_NEWDAT	0x8000
> -#define PCH_IF_MCONT_INTPND	0x2000
> -#define PCH_IF_MCONT_UMASK	0x1000
> -#define PCH_IF_MCONT_TXIE	0x0800
> -#define PCH_IF_MCONT_RXIE	0x0400
> -#define PCH_IF_MCONT_RMTEN	0x0200
> -#define PCH_IF_MCONT_TXRQXT	0x0100
> -#define PCH_IF_MCONT_EOB	0x0080
> -#define PCH_IF_MCONT_DLC	0x000f
> -#define PCH_IF_MCONT_MSGLOST	0x4000
> -#define PCH_MASK2_MDIR_MXTD	0xc000
> -#define PCH_ID2_DIR		0x2000
> -#define PCH_ID2_XTD		0x4000
> -#define PCH_ID_MSGVAL		0x8000
> -#define PCH_IF_CREQ_BUSY	0x8000
> +#define PCH_CMASK_NEWDAT	BIT(2)
> +#define PCH_CMASK_CLRINTPND	BIT(3)
> +#define PCH_CMASK_CTRL		BIT(4)
> +#define PCH_CMASK_ARB		BIT(5)
> +#define PCH_CMASK_MASK		BIT(6)
> +#define PCH_CMASK_RDWR		BIT(7)
> +#define PCH_IF_MCONT_NEWDAT	BIT(15)
> +#define PCH_IF_MCONT_MSGLOST	BIT(14)
> +#define PCH_IF_MCONT_INTPND	BIT(13)
> +#define PCH_IF_MCONT_UMASK	BIT(12)
> +#define PCH_IF_MCONT_TXIE	BIT(11)
> +#define PCH_IF_MCONT_RXIE	BIT(10)
> +#define PCH_IF_MCONT_RMTEN	BIT(9)
> +#define PCH_IF_MCONT_TXRQXT	BIT(8)
> +#define PCH_IF_MCONT_EOB	BIT(7)
> +#define PCH_IF_MCONT_DLC	(BIT(0) | BIT(1) | BIT(2) | BIT(3))
> +#define PCH_MASK2_MDIR_MXTD	(BIT(14) | BIT(15))
> +#define PCH_ID2_DIR		BIT(13)
> +#define PCH_ID2_XTD		BIT(14)
> +#define PCH_ID_MSGVAL		BIT(15)
> +#define PCH_IF_CREQ_BUSY	BIT(15)
> =20
>  #define PCH_STATUS_INT		0x8000
>  #define PCH_REC			0x00007f00
>  #define PCH_TEC			0x000000ff
> =20
> -#define PCH_RX_OK		0x00000010
> -#define PCH_TX_OK		0x00000008
> -#define PCH_BUS_OFF		0x00000080
> -#define PCH_EWARN		0x00000040
> -#define PCH_EPASSIV		0x00000020
> -#define PCH_LEC0		0x00000001
> -#define PCH_LEC1		0x00000002
> -#define PCH_LEC2		0x00000004
> +#define PCH_TX_OK		BIT(3)
> +#define PCH_RX_OK		BIT(4)
> +#define PCH_EPASSIV		BIT(5)
> +#define PCH_EWARN		BIT(6)
> +#define PCH_BUS_OFF		BIT(7)
> +#define PCH_LEC0		BIT(0)
> +#define PCH_LEC1		BIT(1)
> +#define PCH_LEC2		BIT(2)
>  #define PCH_LEC_ALL		(PCH_LEC0 | PCH_LEC1 | PCH_LEC2)
>  #define PCH_STUF_ERR		PCH_LEC0
>  #define PCH_FORM_ERR		PCH_LEC1


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigD78484C5CF4FA3153FBA1420
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzj0tkACgkQjTAFq1RaXHMbGQCfVxoVtwlXphw44uODAlEaqM8J
06AAoIsRtLK+ZzCx9C9vP9a9TeJVTR+v
=XkfX
-----END PGP SIGNATURE-----

--------------enigD78484C5CF4FA3153FBA1420--

--===============1329706560981547680==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============1329706560981547680==--
