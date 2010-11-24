From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 10/17 v3] can: EG20T PCH: Fix coding rule
	violation
Date: Wed, 24 Nov 2010 14:54:40 +0100
Message-ID: <4CED1920.60904@pengutronix.de>
References: <4CED031E.7030403@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2418144870707113249=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CED031E.7030403-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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
--===============2418144870707113249==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig852AA05FABA7749A1B5F875A"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig852AA05FABA7749A1B5F875A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/24/2010 01:20 PM, Tomoya MORINAGA wrote:
> Fix coding rule violation.
>=20
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>

Fix my comment (see online) , check if the lines stay (mostly) <=3D 80
chars and add my Acked-by.

cheers, Marc

> ---
>  drivers/net/can/pch_can.c |   48
> ++++++++++++++++++++------------------------
>  1 files changed, 22 insertions(+), 26 deletions(-)
>=20
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index e71817d..318eb1f 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -89,9 +89,11 @@
>=20
>  #define PCH_CAN_CLK		50000000	/* 50MHz */
>=20
> -/* Define the number of message object.
> +/*
> + * Define the number of message object.
>   * PCH CAN communications are done via Message RAM.
> - * The Message RAM consists of 32 message objects. */
> + * The Message RAM consists of 32 message objects.
> + */
>  #define PCH_RX_OBJ_NUM		26
>  #define PCH_TX_OBJ_NUM		6
>  #define PCH_RX_OBJ_START	1
> @@ -126,7 +128,7 @@ enum pch_can_mode {
>  	PCH_CAN_ALL,
>  	PCH_CAN_NONE,
>  	PCH_CAN_STOP,
> -	PCH_CAN_RUN
> +	PCH_CAN_RUN,
>  };
>=20
>  struct pch_can_if_regs {
> @@ -290,21 +292,20 @@ static void pch_can_set_rxtx(struct pch_can_priv
> *priv, u32 buff_num,
>  	else
>  		ie =3D PCH_IF_MCONT_RXIE;
>=20
> -	/* Reading the receive buffer data from RAM to Interface1 registers *=
/
> +	/* Reading the receive buffer data from RAM to Interface1/2 registers=
 */
>  	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
>  	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
>=20
> -	/* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
> +	/* Setting the IF1/2MASK1 register to access MsgVal and RxIE bits */
>  	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  		  &priv->regs->ifregs[dir].cmask);
>=20
>  	if (set) {
> -		/* Setting the MsgVal and RxIE bits */
> +		/* Setting the MsgVal and RxIE/TxIE bits */
>  		pch_can_bit_set(&priv->regs->ifregs[dir].mcont, ie);
>  		pch_can_bit_set(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
> -
>  	} else {
> -		/* Resetting the MsgVal and RxIE bits */
> +		/* Clearing the MsgVal and RxIE/TxIE bits */
>  		pch_can_bit_clear(&priv->regs->ifregs[dir].mcont, ie);
>  		pch_can_bit_clear(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
>  	}
> @@ -312,7 +313,6 @@ static void pch_can_set_rxtx(struct pch_can_priv
> *priv, u32 buff_num,
>  	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
>  }
>=20
> -
>  static void pch_can_set_rx_all(struct pch_can_priv *priv, int set)
>  {
>  	int i;
> @@ -328,7 +328,7 @@ static void pch_can_set_tx_all(struct pch_can_priv
> *priv, int set)
>=20
>  	/* Traversing to obtain the object configured as transmit object. */
>  	for (i =3D PCH_TX_OBJ_START; i <=3D PCH_TX_OBJ_END; i++)
> -		pch_can_set_rxtx(priv, i, set, 1);
> +		pch_can_set_rxtx(priv, i, set, PCH_TX_IFREG);

this should be folded into the patch 1 (along with the introduction of
the enums)

>  }
>=20
>  static u32 pch_can_int_pending(struct pch_can_priv *priv)
> @@ -363,8 +363,7 @@ static void pch_can_config_rx_tx_buffers(struct
> pch_can_priv *priv)
>  	int i;
>=20
>  	for (i =3D PCH_RX_OBJ_START; i <=3D PCH_RX_OBJ_END; i++) {
> -		iowrite32(PCH_CMASK_RX_TX_GET,
> -			&priv->regs->ifregs[0].cmask);
> +		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
>  		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
>=20
>  		iowrite32(0x0, &priv->regs->ifregs[0].id1);
> @@ -386,16 +385,14 @@ static void pch_can_config_rx_tx_buffers(struct
> pch_can_priv *priv)
>  				  0x1fff | PCH_MASK2_MDIR_MXTD);
>=20
>  		/* Setting CMASK for writing */
> -		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
> -			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
> -			  &priv->regs->ifregs[0].cmask);
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK | PCH_CMASK_ARB |
> +			  PCH_CMASK_CTRL, &priv->regs->ifregs[0].cmask);
>=20
>  		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
>  	}
>=20
>  	for (i =3D PCH_TX_OBJ_START; i <=3D PCH_TX_OBJ_END; i++) {
> -		iowrite32(PCH_CMASK_RX_TX_GET,
> -			&priv->regs->ifregs[1].cmask);
> +		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
>  		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, i);
>=20
>  		/* Resetting DIR bit for reception */
> @@ -410,9 +407,8 @@ static void pch_can_config_rx_tx_buffers(struct
> pch_can_priv *priv)
>  		pch_can_bit_clear(&priv->regs->ifregs[1].mask2, 0x1fff);
>=20
>  		/* Setting CMASK for writing */
> -		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
> -			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
> -			  &priv->regs->ifregs[1].cmask);
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK | PCH_CMASK_ARB |
> +			  PCH_CMASK_CTRL, &priv->regs->ifregs[1].cmask);
>=20
>  		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, i);
>  	}
> @@ -471,8 +467,9 @@ static void pch_can_int_clr(struct pch_can_priv
> *priv, u32 mask)
>=20
>  		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, mask);
>  	} else if ((mask >=3D PCH_TX_OBJ_START) && (mask <=3D PCH_TX_OBJ_END)=
) {
> -		/* Setting CMASK for clearing interrupts for
> -					 frame transmission. */
> +		/*
> +		 * Setting CMASK for clearing interrupts for frame transmission.
> +		 */
>  		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
>  			  &priv->regs->ifregs[1].cmask);
>=20
> @@ -600,7 +597,6 @@ static irqreturn_t pch_can_interrupt(int irq, void
> *dev_id)
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
>=20
>  	pch_can_set_int_enables(priv, PCH_CAN_NONE);
> -
>  	napi_schedule(&priv->napi);
>=20
>  	return IRQ_HANDLED;
> @@ -1048,11 +1044,11 @@ static u32 pch_can_get_rxtx_ir(struct
> pch_can_priv *priv, u32 buff_num, u32 dir)
>  	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
>=20
>  	if (((ioread32(&priv->regs->ifregs[dir].id2)) & PCH_ID_MSGVAL) &&
> -			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie)) {
> +			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie))
>  		enable =3D 1;
> -	} else {
> +	else
>  		enable =3D 0;
> -	}
> +
>  	return enable;
>  }
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig852AA05FABA7749A1B5F875A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEUEARECAAYFAkztGSMACgkQjTAFq1RaXHPfCwCY4gdViZg6NokQeZDfdnet9MkR
EQCfYOBfiF2jG00mVT8M/HAWeFmR+nA=
=fpRn
-----END PGP SIGNATURE-----

--------------enig852AA05FABA7749A1B5F875A--

--===============2418144870707113249==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============2418144870707113249==--
