From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next-2.6 ] can: EG20T PCH: add  prefix to macro
Date: Wed, 17 Nov 2010 10:12:28 +0100
Message-ID: <4CE39C7C.9040006@pengutronix.de>
References: <4CE3648D.2070102@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4826C95ADCF306F735458579"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andrew.chih.howe.khor@intel.com,
	qi.wang@intel.com, margie.foster@intel.com, yong.y.wang@intel.com,
	kok.howg.ewe@intel.com, joel.clark@intel.com
To: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37681 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933323Ab0KQJMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 04:12:52 -0500
In-Reply-To: <4CE3648D.2070102@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4826C95ADCF306F735458579
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/17/2010 06:13 AM, Tomoya MORINAGA wrote:
> For easy to readable/identifiable, add prefix "PCH_" to all of #define =
macros.
>=20
> Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>

You broke the indention in some lines, fix it and add my:
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

cheers, Marc

> ---
>  drivers/net/can/pch_can.c |  392 ++++++++++++++++++++++---------------=
--------
>  1 files changed, 190 insertions(+), 202 deletions(-)
>=20
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index 6727182..b4bb775 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -32,49 +32,48 @@
>  #include <linux/can/dev.h>
>  #include <linux/can/error.h>
> =20
> -#define MAX_MSG_OBJ		32
> -#define MSG_OBJ_RX		0 /* The receive message object flag. */
> -#define MSG_OBJ_TX		1 /* The transmit message object flag. */
> -
> -#define ENABLE			1 /* The enable flag */
> -#define DISABLE			0 /* The disable flag */
> -#define CAN_CTRL_INIT		0x0001 /* The INIT bit of CANCONT register. */
> -#define CAN_CTRL_IE		0x0002 /* The IE bit of CAN control register */
> -#define CAN_CTRL_IE_SIE_EIE	0x000e
> -#define CAN_CTRL_CCE		0x0040
> -#define CAN_CTRL_OPT		0x0080 /* The OPT bit of CANCONT register. */
> -#define CAN_OPT_SILENT		0x0008 /* The Silent bit of CANOPT reg. */
> -#define CAN_OPT_LBACK		0x0010 /* The LoopBack bit of CANOPT reg. */
> -#define CAN_CMASK_RX_TX_SET	0x00f3
> -#define CAN_CMASK_RX_TX_GET	0x0073
> -#define CAN_CMASK_ALL		0xff
> -#define CAN_CMASK_RDWR		0x80
> -#define CAN_CMASK_ARB		0x20
> -#define CAN_CMASK_CTRL		0x10
> -#define CAN_CMASK_MASK		0x40
> -#define CAN_CMASK_NEWDAT	0x04
> -#define CAN_CMASK_CLRINTPND	0x08
> -
> -#define CAN_IF_MCONT_NEWDAT	0x8000
> -#define CAN_IF_MCONT_INTPND	0x2000
> -#define CAN_IF_MCONT_UMASK	0x1000
> -#define CAN_IF_MCONT_TXIE	0x0800
> -#define CAN_IF_MCONT_RXIE	0x0400
> -#define CAN_IF_MCONT_RMTEN	0x0200
> -#define CAN_IF_MCONT_TXRQXT	0x0100
> -#define CAN_IF_MCONT_EOB	0x0080
> -#define CAN_IF_MCONT_DLC	0x000f
> -#define CAN_IF_MCONT_MSGLOST	0x4000
> -#define CAN_MASK2_MDIR_MXTD	0xc000
> -#define CAN_ID2_DIR		0x2000
> -#define CAN_ID_MSGVAL		0x8000
> -
> -#define CAN_STATUS_INT		0x8000
> -#define CAN_IF_CREQ_BUSY	0x8000
> -#define CAN_ID2_XTD		0x4000
> -
> -#define CAN_REC			0x00007f00
> -#define CAN_TEC			0x000000ff
> +#define PCH_MAX_MSG_OBJ		32
> +#define PCH_MSG_OBJ_RX		0 /* The receive message object flag. */
> +#define PCH_MSG_OBJ_TX		1 /* The transmit message object flag. */
> +
> +#define PCH_ENABLE			1 /* The enable flag */
> +#define PCH_DISABLE			0 /* The disable flag */

^^^ here

> +#define PCH_CTRL_INIT		0x0001 /* The INIT bit of CANCONT register. */
> +#define PCH_CTRL_IE		0x0002 /* The IE bit of CAN control register */
> +#define PCH_CTRL_IE_SIE_EIE	0x000e
> +#define PCH_CTRL_CCE		0x0040
> +#define PCH_CTRL_OPT		0x0080 /* The OPT bit of CANCONT register. */
> +#define PCH_OPT_SILENT		0x0008 /* The Silent bit of CANOPT reg. */
> +#define PCH_OPT_LBACK		0x0010 /* The LoopBack bit of CANOPT reg. */
> +#define PCH_CMASK_RX_TX_SET	0x00f3
> +#define PCH_CMASK_RX_TX_GET	0x0073
> +#define PCH_CMASK_ALL		0xff
> +#define PCH_CMASK_RDWR		0x80
> +#define PCH_CMASK_ARB		0x20
> +#define PCH_CMASK_CTRL		0x10
> +#define PCH_CMASK_MASK		0x40
> +#define PCH_CMASK_NEWDAT	0x04
> +#define PCH_CMASK_CLRINTPND	0x08
> +#define PCH_IF_MCONT_NEWDAT	0x8000
> +#define PCH_IF_MCONT_INTPND	0x2000
> +#define PCH_IF_MCONT_UMASK	0x1000
> +#define PCH_IF_MCONT_TXIE	0x0800
> +#define PCH_IF_MCONT_RXIE	0x0400
> +#define PCH_IF_MCONT_RMTEN	0x0200
> +#define PCH_IF_MCONT_TXRQXT	0x0100
> +#define PCH_IF_MCONT_EOB	0x0080
> +#define PCH_IF_MCONT_DLC	0x000f
> +#define PCH_IF_MCONT_MSGLOST	0x4000
> +#define PCH_MASK2_MDIR_MXTD	0xc000
> +#define PCH_ID2_DIR		0x2000
> +#define PCH_ID2_XTD		0x4000
> +#define PCH_ID_MSGVAL		0x8000
> +#define PCH_IF_CREQ_BUSY	0x8000
> +
> +#define PCH_STATUS_INT		0x8000
> +#define PCH_REC			0x00007f00
> +#define PCH_TEC			0x000000ff
> +
> =20
>  #define PCH_RX_OK		0x00000010
>  #define PCH_TX_OK		0x00000008
> @@ -93,26 +92,15 @@
>  #define PCH_CRC_ERR		(PCH_LEC1 | PCH_LEC2)
> =20
>  /* bit position of certain controller bits. */
> -#define BIT_BITT_BRP		0
> -#define BIT_BITT_SJW		6
> -#define BIT_BITT_TSEG1		8
> -#define BIT_BITT_TSEG2		12
> -#define BIT_IF1_MCONT_RXIE	10
> -#define BIT_IF2_MCONT_TXIE	11
> -#define BIT_BRPE_BRPE		6
> -#define BIT_ES_TXERRCNT		0
> -#define BIT_ES_RXERRCNT		8
> -#define MSK_BITT_BRP		0x3f
> -#define MSK_BITT_SJW		0xc0
> -#define MSK_BITT_TSEG1		0xf00
> -#define MSK_BITT_TSEG2		0x7000
> -#define MSK_BRPE_BRPE		0x3c0
> -#define MSK_BRPE_GET		0x0f
> -#define MSK_CTRL_IE_SIE_EIE	0x07
> -#define MSK_MCONT_TXIE		0x08
> -#define MSK_MCONT_RXIE		0x10
> -#define PCH_CAN_NO_TX_BUFF	1
> -#define COUNTER_LIMIT		10
> +#define PCH_BIT_BRP		0
> +#define PCH_BIT_SJW		6
> +#define PCH_BIT_TSEG1		8
> +#define PCH_BIT_TSEG2		12
> +#define PCH_BIT_BRPE_BRPE		6
> +#define PCH_MSK_BITT_BRP		0x3f
> +#define PCH_MSK_BRPE_BRPE		0x3c0

^^^ here

> +#define PCH_MSK_CTRL_IE_SIE_EIE	0x07
> +#define PCH_COUNTER_LIMIT		10
> =20
>  #define PCH_CAN_CLK		50000000	/* 50MHz */
> =20
> @@ -181,14 +169,14 @@ struct pch_can_priv {
>  	struct can_priv can;
>  	unsigned int can_num;
>  	struct pci_dev *dev;
> -	unsigned int tx_enable[MAX_MSG_OBJ];
> -	unsigned int rx_enable[MAX_MSG_OBJ];
> -	unsigned int rx_link[MAX_MSG_OBJ];
> +	unsigned int tx_enable[PCH_MAX_MSG_OBJ];
> +	unsigned int rx_enable[PCH_MAX_MSG_OBJ];
> +	unsigned int rx_link[PCH_MAX_MSG_OBJ];
>  	unsigned int int_enables;
>  	unsigned int int_stat;
>  	struct net_device *ndev;
>  	spinlock_t msgif_reg_lock; /* Message Interface Registers Access Lock=
*/
> -	unsigned int msg_obj[MAX_MSG_OBJ];
> +	unsigned int msg_obj[PCH_MAX_MSG_OBJ];
>  	struct pch_can_regs __iomem *regs;
>  	struct napi_struct napi;
>  	unsigned int tx_obj;	/* Point next Tx Obj index */
> @@ -228,11 +216,11 @@ static void pch_can_set_run_mode(struct pch_can_p=
riv *priv,
>  {
>  	switch (mode) {
>  	case PCH_CAN_RUN:
> -		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_INIT);
> +		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_INIT);
>  		break;
> =20
>  	case PCH_CAN_STOP:
> -		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_INIT);
> +		pch_can_bit_set(&priv->regs->cont, PCH_CTRL_INIT);
>  		break;
> =20
>  	default:
> @@ -246,30 +234,30 @@ static void pch_can_set_optmode(struct pch_can_pr=
iv *priv)
>  	u32 reg_val =3D ioread32(&priv->regs->opt);
> =20
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
> -		reg_val |=3D CAN_OPT_SILENT;
> +		reg_val |=3D PCH_OPT_SILENT;
> =20
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
> -		reg_val |=3D CAN_OPT_LBACK;
> +		reg_val |=3D PCH_OPT_LBACK;
> =20
> -	pch_can_bit_set(&priv->regs->cont, CAN_CTRL_OPT);
> +	pch_can_bit_set(&priv->regs->cont, PCH_CTRL_OPT);
>  	iowrite32(reg_val, &priv->regs->opt);
>  }
> =20
>  static void pch_can_set_int_custom(struct pch_can_priv *priv)
>  {
>  	/* Clearing the IE, SIE and EIE bits of Can control register. */
> -	pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
> +	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
> =20
>  	/* Appropriately setting them. */
>  	pch_can_bit_set(&priv->regs->cont,
> -			((priv->int_enables & MSK_CTRL_IE_SIE_EIE) << 1));
> +			((priv->int_enables & PCH_MSK_CTRL_IE_SIE_EIE) << 1));
>  }
> =20
>  /* This function retrieves interrupt enabled for the CAN device. */
>  static void pch_can_get_int_enables(struct pch_can_priv *priv, u32 *en=
ables)
>  {
>  	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
> -	*enables =3D ((ioread32(&priv->regs->cont) & CAN_CTRL_IE_SIE_EIE) >> =
1);
> +	*enables =3D ((ioread32(&priv->regs->cont) & PCH_CTRL_IE_SIE_EIE) >> =
1);
>  }
> =20
>  static void pch_can_set_int_enables(struct pch_can_priv *priv,
> @@ -277,19 +265,19 @@ static void pch_can_set_int_enables(struct pch_ca=
n_priv *priv,
>  {
>  	switch (interrupt_no) {
>  	case PCH_CAN_ENABLE:
> -		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_IE);
> +		pch_can_bit_set(&priv->regs->cont, PCH_CTRL_IE);
>  		break;
> =20
>  	case PCH_CAN_DISABLE:
> -		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE);
> +		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE);
>  		break;
> =20
>  	case PCH_CAN_ALL:
> -		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
> +		pch_can_bit_set(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
>  		break;
> =20
>  	case PCH_CAN_NONE:
> -		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
> +		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
>  		break;
> =20
>  	default:
> @@ -300,12 +288,12 @@ static void pch_can_set_int_enables(struct pch_ca=
n_priv *priv,
> =20
>  static void pch_can_check_if_busy(u32 __iomem *creq_addr, u32 num)
>  {
> -	u32 counter =3D COUNTER_LIMIT;
> +	u32 counter =3D PCH_COUNTER_LIMIT;
>  	u32 ifx_creq;
> =20
>  	iowrite32(num, creq_addr);
>  	while (counter) {
> -		ifx_creq =3D ioread32(creq_addr) & CAN_IF_CREQ_BUSY;
> +		ifx_creq =3D ioread32(creq_addr) & PCH_IF_CREQ_BUSY;
>  		if (!ifx_creq)
>  			break;
>  		counter--;
> @@ -322,22 +310,22 @@ static void pch_can_set_rx_enable(struct pch_can_=
priv *priv, u32 buff_num,
> =20
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
>  	/* Reading the receive buffer data from RAM to Interface1 registers *=
/
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
>  	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> =20
>  	/* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
> -	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL,
> +	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  		  &priv->regs->if1_cmask);
> =20
> -	if (set =3D=3D ENABLE) {
> +	if (set =3D=3D PCH_ENABLE) {
>  		/* Setting the MsgVal and RxIE bits */
> -		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_RXIE);
> -		pch_can_bit_set(&priv->regs->if1_id2, CAN_ID_MSGVAL);
> +		pch_can_bit_set(&priv->regs->if1_mcont, PCH_IF_MCONT_RXIE);
> +		pch_can_bit_set(&priv->regs->if1_id2, PCH_ID_MSGVAL);
> =20
> -	} else if (set =3D=3D DISABLE) {
> +	} else if (set =3D=3D PCH_DISABLE) {
>  		/* Resetting the MsgVal and RxIE bits */
> -		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_RXIE);
> -		pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID_MSGVAL);
> +		pch_can_bit_clear(&priv->regs->if1_mcont, PCH_IF_MCONT_RXIE);
> +		pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID_MSGVAL);
>  	}
> =20
>  	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> @@ -350,8 +338,8 @@ static void pch_can_rx_enable_all(struct pch_can_pr=
iv *priv)
> =20
>  	/* Traversing to obtain the object configured as receivers. */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX)
> -			pch_can_set_rx_enable(priv, i + 1, ENABLE);
> +		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_RX)
> +			pch_can_set_rx_enable(priv, i + 1, PCH_ENABLE);
>  	}
>  }
> =20
> @@ -361,8 +349,8 @@ static void pch_can_rx_disable_all(struct pch_can_p=
riv *priv)
> =20
>  	/* Traversing to obtain the object configured as receivers. */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX)
> -			pch_can_set_rx_enable(priv, i + 1, DISABLE);
> +		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_RX)
> +			pch_can_set_rx_enable(priv, i + 1, PCH_DISABLE);
>  	}
>  }
> =20
> @@ -373,22 +361,22 @@ static void pch_can_set_tx_enable(struct pch_can_=
priv *priv, u32 buff_num,
> =20
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
>  	/* Reading the Msg buffer from Message RAM to Interface2 registers. *=
/
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
>  	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> =20
>  	/* Setting the IF2CMASK register for accessing the
>  		MsgVal and TxIE bits */
> -	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL,
> +	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  		 &priv->regs->if2_cmask);
> =20
> -	if (set =3D=3D ENABLE) {
> +	if (set =3D=3D PCH_ENABLE) {
>  		/* Setting the MsgVal and TxIE bits */
> -		pch_can_bit_set(&priv->regs->if2_mcont, CAN_IF_MCONT_TXIE);
> -		pch_can_bit_set(&priv->regs->if2_id2, CAN_ID_MSGVAL);
> -	} else if (set =3D=3D DISABLE) {
> +		pch_can_bit_set(&priv->regs->if2_mcont, PCH_IF_MCONT_TXIE);
> +		pch_can_bit_set(&priv->regs->if2_id2, PCH_ID_MSGVAL);
> +	} else if (set =3D=3D PCH_DISABLE) {
>  		/* Resetting the MsgVal and TxIE bits. */
> -		pch_can_bit_clear(&priv->regs->if2_mcont, CAN_IF_MCONT_TXIE);
> -		pch_can_bit_clear(&priv->regs->if2_id2, CAN_ID_MSGVAL);
> +		pch_can_bit_clear(&priv->regs->if2_mcont, PCH_IF_MCONT_TXIE);
> +		pch_can_bit_clear(&priv->regs->if2_id2, PCH_ID_MSGVAL);
>  	}
> =20
>  	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> @@ -401,8 +389,8 @@ static void pch_can_tx_enable_all(struct pch_can_pr=
iv *priv)
> =20
>  	/* Traversing to obtain the object configured as transmit object. */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX)
> -			pch_can_set_tx_enable(priv, i + 1, ENABLE);
> +		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX)
> +			pch_can_set_tx_enable(priv, i + 1, PCH_ENABLE);
>  	}
>  }
> =20
> @@ -412,8 +400,8 @@ static void pch_can_tx_disable_all(struct pch_can_p=
riv *priv)
> =20
>  	/* Traversing to obtain the object configured as transmit object. */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX)
> -			pch_can_set_tx_enable(priv, i + 1, DISABLE);
> +		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX)
> +			pch_can_set_tx_enable(priv, i + 1, PCH_DISABLE);
>  	}
>  }
> =20
> @@ -423,15 +411,15 @@ static void pch_can_get_rx_enable(struct pch_can_=
priv *priv, u32 buff_num,
>  	unsigned long flags;
> =20
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
>  	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> =20
> -	if (((ioread32(&priv->regs->if1_id2)) & CAN_ID_MSGVAL) &&
> +	if (((ioread32(&priv->regs->if1_id2)) & PCH_ID_MSGVAL) &&
>  			((ioread32(&priv->regs->if1_mcont)) &
> -			CAN_IF_MCONT_RXIE))
> -		*enable =3D ENABLE;
> +			PCH_IF_MCONT_RXIE))
> +		*enable =3D PCH_ENABLE;
>  	else
> -		*enable =3D DISABLE;
> +		*enable =3D PCH_DISABLE;
>  	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>  }
> =20
> @@ -441,15 +429,15 @@ static void pch_can_get_tx_enable(struct pch_can_=
priv *priv, u32 buff_num,
>  	unsigned long flags;
> =20
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
>  	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> =20
> -	if (((ioread32(&priv->regs->if2_id2)) & CAN_ID_MSGVAL) &&
> +	if (((ioread32(&priv->regs->if2_id2)) & PCH_ID_MSGVAL) &&
>  			((ioread32(&priv->regs->if2_mcont)) &
> -			CAN_IF_MCONT_TXIE)) {
> -		*enable =3D ENABLE;
> +			PCH_IF_MCONT_TXIE)) {
> +		*enable =3D PCH_ENABLE;
>  	} else {
> -		*enable =3D DISABLE;
> +		*enable =3D PCH_DISABLE;
>  	}
>  	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>  }
> @@ -465,13 +453,13 @@ static void pch_can_set_rx_buffer_link(struct pch=
_can_priv *priv,
>  	unsigned long flags;
> =20
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
>  	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> -	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL, &priv->regs->if1_cmask);
> -	if (set =3D=3D ENABLE)
> -		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
> +	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL, &priv->regs->if1_cmask);
> +	if (set =3D=3D PCH_ENABLE)
> +		pch_can_bit_clear(&priv->regs->if1_mcont, PCH_IF_MCONT_EOB);
>  	else
> -		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
> +		pch_can_bit_set(&priv->regs->if1_mcont, PCH_IF_MCONT_EOB);
> =20
>  	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
>  	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> @@ -483,13 +471,13 @@ static void pch_can_get_rx_buffer_link(struct pch=
_can_priv *priv,
>  	unsigned long flags;
> =20
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
>  	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> =20
> -	if (ioread32(&priv->regs->if1_mcont) & CAN_IF_MCONT_EOB)
> -		*link =3D DISABLE;
> +	if (ioread32(&priv->regs->if1_mcont) & PCH_IF_MCONT_EOB)
> +		*link =3D PCH_DISABLE;
>  	else
> -		*link =3D ENABLE;
> +		*link =3D PCH_ENABLE;
>  	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>  }
> =20
> @@ -498,7 +486,7 @@ static void pch_can_clear_buffers(struct pch_can_pr=
iv *priv)
>  	int i;
> =20
>  	for (i =3D 0; i < PCH_RX_OBJ_NUM; i++) {
> -		iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if1_cmask);
> +		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->if1_cmask);
>  		iowrite32(0xffff, &priv->regs->if1_mask1);
>  		iowrite32(0xffff, &priv->regs->if1_mask2);
>  		iowrite32(0x0, &priv->regs->if1_id1);
> @@ -508,14 +496,14 @@ static void pch_can_clear_buffers(struct pch_can_=
priv *priv)
>  		iowrite32(0x0, &priv->regs->if1_dataa2);
>  		iowrite32(0x0, &priv->regs->if1_datab1);
>  		iowrite32(0x0, &priv->regs->if1_datab2);
> -		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
> -			  CAN_CMASK_ARB | CAN_CMASK_CTRL,
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
> +			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  			  &priv->regs->if1_cmask);
>  		pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
>  	}
> =20
>  	for (i =3D i;  i < PCH_OBJ_NUM; i++) {
> -		iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if2_cmask);
> +		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->if2_cmask);
>  		iowrite32(0xffff, &priv->regs->if2_mask1);
>  		iowrite32(0xffff, &priv->regs->if2_mask2);
>  		iowrite32(0x0, &priv->regs->if2_id1);
> @@ -525,8 +513,8 @@ static void pch_can_clear_buffers(struct pch_can_pr=
iv *priv)
>  		iowrite32(0x0, &priv->regs->if2_dataa2);
>  		iowrite32(0x0, &priv->regs->if2_datab1);
>  		iowrite32(0x0, &priv->regs->if2_datab2);
> -		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
> -			  CAN_CMASK_ARB | CAN_CMASK_CTRL,
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
> +			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  			  &priv->regs->if2_cmask);
>  		pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
>  	}
> @@ -540,8 +528,8 @@ static void pch_can_config_rx_tx_buffers(struct pch=
_can_priv *priv)
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> =20
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX) {
> -			iowrite32(CAN_CMASK_RX_TX_GET,
> +		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_RX) {
> +			iowrite32(PCH_CMASK_RX_TX_GET,
>  				&priv->regs->if1_cmask);
>  			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
> =20
> @@ -549,48 +537,48 @@ static void pch_can_config_rx_tx_buffers(struct p=
ch_can_priv *priv)
>  			iowrite32(0x0, &priv->regs->if1_id2);
> =20
>  			pch_can_bit_set(&priv->regs->if1_mcont,
> -					CAN_IF_MCONT_UMASK);
> +					PCH_IF_MCONT_UMASK);
> =20
>  			/* Set FIFO mode set to 0 except last Rx Obj*/
>  			pch_can_bit_clear(&priv->regs->if1_mcont,
> -					  CAN_IF_MCONT_EOB);
> +					  PCH_IF_MCONT_EOB);
>  			/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
>  			if (i =3D=3D (PCH_RX_OBJ_NUM - 1))
>  				pch_can_bit_set(&priv->regs->if1_mcont,
> -						  CAN_IF_MCONT_EOB);
> +						  PCH_IF_MCONT_EOB);
> =20
>  			iowrite32(0, &priv->regs->if1_mask1);
>  			pch_can_bit_clear(&priv->regs->if1_mask2,
> -					  0x1fff | CAN_MASK2_MDIR_MXTD);
> +					  0x1fff | PCH_MASK2_MDIR_MXTD);
> =20
>  			/* Setting CMASK for writing */
> -			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
> -				  CAN_CMASK_ARB | CAN_CMASK_CTRL,
> +			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
> +				  PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  				  &priv->regs->if1_cmask);
> =20
>  			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
> -		} else if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX) {
> -			iowrite32(CAN_CMASK_RX_TX_GET,
> +		} else if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX) {
> +			iowrite32(PCH_CMASK_RX_TX_GET,
>  				&priv->regs->if2_cmask);
>  			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
> =20
>  			/* Resetting DIR bit for reception */
>  			iowrite32(0x0, &priv->regs->if2_id1);
>  			iowrite32(0x0, &priv->regs->if2_id2);
> -			pch_can_bit_set(&priv->regs->if2_id2, CAN_ID2_DIR);
> +			pch_can_bit_set(&priv->regs->if2_id2, PCH_ID2_DIR);
> =20
>  			/* Setting EOB bit for transmitter */
> -			iowrite32(CAN_IF_MCONT_EOB, &priv->regs->if2_mcont);
> +			iowrite32(PCH_IF_MCONT_EOB, &priv->regs->if2_mcont);
> =20
>  			pch_can_bit_set(&priv->regs->if2_mcont,
> -					CAN_IF_MCONT_UMASK);
> +					PCH_IF_MCONT_UMASK);
> =20
>  			iowrite32(0, &priv->regs->if2_mask1);
>  			pch_can_bit_clear(&priv->regs->if2_mask2, 0x1fff);
> =20
>  			/* Setting CMASK for writing */
> -			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
> -				  CAN_CMASK_ARB | CAN_CMASK_CTRL,
> +			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
> +				  PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  				  &priv->regs->if2_cmask);
> =20
>  			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
> @@ -632,39 +620,39 @@ static void pch_can_release(struct pch_can_priv *=
priv)
>  /* This function clears interrupt(s) from the CAN device. */
>  static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
>  {
> -	if (mask =3D=3D CAN_STATUS_INT) {
> +	if (mask =3D=3D PCH_STATUS_INT) {
>  		ioread32(&priv->regs->stat);
>  		return;
>  	}
> =20
>  	/* Clear interrupt for transmit object */
> -	if (priv->msg_obj[mask - 1] =3D=3D MSG_OBJ_TX) {
> +	if (priv->msg_obj[mask - 1] =3D=3D PCH_MSG_OBJ_TX) {
>  		/* Setting CMASK for clearing interrupts for
>  					 frame transmission. */
> -		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB,
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
>  			  &priv->regs->if2_cmask);
> =20
>  		/* Resetting the ID registers. */
>  		pch_can_bit_set(&priv->regs->if2_id2,
> -			       CAN_ID2_DIR | (0x7ff << 2));
> +			       PCH_ID2_DIR | (0x7ff << 2));
>  		iowrite32(0x0, &priv->regs->if2_id1);
> =20
>  		/* Claring NewDat, TxRqst & IntPnd */
>  		pch_can_bit_clear(&priv->regs->if2_mcont,
> -				  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND |
> -				  CAN_IF_MCONT_TXRQXT);
> +				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
> +				  PCH_IF_MCONT_TXRQXT);
>  		pch_can_check_if_busy(&priv->regs->if2_creq, mask);
> -	} else if (priv->msg_obj[mask - 1] =3D=3D MSG_OBJ_RX) {
> +	} else if (priv->msg_obj[mask - 1] =3D=3D PCH_MSG_OBJ_RX) {
>  		/* Setting CMASK for clearing the reception interrupts. */
> -		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB,
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
>  			  &priv->regs->if1_cmask);
> =20
>  		/* Clearing the Dir bit. */
> -		pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID2_DIR);
> +		pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID2_DIR);
> =20
>  		/* Clearing NewDat & IntPnd */
>  		pch_can_bit_clear(&priv->regs->if1_mcont,
> -				  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND);
> +				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND);
> =20
>  		pch_can_check_if_busy(&priv->regs->if1_creq, mask);
>  	}
> @@ -712,9 +700,9 @@ static void pch_can_error(struct net_device *ndev, =
u32 status)
>  		priv->can.can_stats.error_warning++;
>  		cf->can_id |=3D CAN_ERR_CRTL;
>  		errc =3D ioread32(&priv->regs->errc);
> -		if (((errc & CAN_REC) >> 8) > 96)
> +		if (((errc & PCH_REC) >> 8) > 96)
>  			cf->data[1] |=3D CAN_ERR_CRTL_RX_WARNING;
> -		if ((errc & CAN_TEC) > 96)
> +		if ((errc & PCH_TEC) > 96)
>  			cf->data[1] |=3D CAN_ERR_CRTL_TX_WARNING;
>  		dev_warn(&ndev->dev,
>  			"%s -> Error Counter is more than 96.\n", __func__);
> @@ -725,9 +713,9 @@ static void pch_can_error(struct net_device *ndev, =
u32 status)
>  		state =3D CAN_STATE_ERROR_PASSIVE;
>  		cf->can_id |=3D CAN_ERR_CRTL;
>  		errc =3D ioread32(&priv->regs->errc);
> -		if (((errc & CAN_REC) >> 8) > 127)
> +		if (((errc & PCH_REC) >> 8) > 127)
>  			cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
> -		if ((errc & CAN_TEC) > 127)
> +		if ((errc & PCH_TEC) > 127)
>  			cf->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
>  		dev_err(&ndev->dev,
>  			"%s -> CAN controller is ERROR PASSIVE .\n", __func__);
> @@ -795,20 +783,20 @@ static int pch_can_rx_normal(struct net_device *n=
dev, u32 int_stat)
>  	struct net_device_stats *stats =3D &(priv->ndev->stats);
> =20
>  	/* Reading the messsage object from the Message RAM */
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
>  	pch_can_check_if_busy(&priv->regs->if1_creq, int_stat);
> =20
>  	/* Reading the MCONT register. */
>  	reg =3D ioread32(&priv->regs->if1_mcont);
>  	reg &=3D 0xffff;
> =20
> -	for (k =3D int_stat; !(reg & CAN_IF_MCONT_EOB); k++) {
> +	for (k =3D int_stat; !(reg & PCH_IF_MCONT_EOB); k++) {
>  		/* If MsgLost bit set. */
> -		if (reg & CAN_IF_MCONT_MSGLOST) {
> +		if (reg & PCH_IF_MCONT_MSGLOST) {
>  			dev_err(&priv->ndev->dev, "Msg Obj is overwritten.\n");
>  			pch_can_bit_clear(&priv->regs->if1_mcont,
> -					  CAN_IF_MCONT_MSGLOST);
> -			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL,
> +					  PCH_IF_MCONT_MSGLOST);
> +			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
>  				  &priv->regs->if1_cmask);
>  			pch_can_check_if_busy(&priv->regs->if1_creq, k);
> =20
> @@ -828,7 +816,7 @@ static int pch_can_rx_normal(struct net_device *nde=
v, u32 int_stat)
>  			rcv_pkts++;
>  			goto RX_NEXT;
>  		}
> -		if (!(reg & CAN_IF_MCONT_NEWDAT))
> +		if (!(reg & PCH_IF_MCONT_NEWDAT))
>  			goto RX_NEXT;
> =20
>  		skb =3D alloc_can_skb(priv->ndev, &cf);
> @@ -836,7 +824,7 @@ static int pch_can_rx_normal(struct net_device *nde=
v, u32 int_stat)
>  			return -ENOMEM;
> =20
>  		/* Get Received data */
> -		ide =3D ((ioread32(&priv->regs->if1_id2)) & CAN_ID2_XTD) >> 14;
> +		ide =3D ((ioread32(&priv->regs->if1_id2)) & PCH_ID2_XTD) >> 14;
>  		if (ide) {
>  			id =3D (ioread32(&priv->regs->if1_id1) & 0xffff);
>  			id |=3D (((ioread32(&priv->regs->if1_id2)) &
> @@ -848,7 +836,7 @@ static int pch_can_rx_normal(struct net_device *nde=
v, u32 int_stat)
>  			cf->can_id =3D (id & CAN_SFF_MASK);
>  		}
> =20
> -		rtr =3D (ioread32(&priv->regs->if1_id2) &  CAN_ID2_DIR);
> +		rtr =3D (ioread32(&priv->regs->if1_id2) &  PCH_ID2_DIR);
>  		if (rtr) {
>  			cf->can_dlc =3D 0;
>  			cf->can_id |=3D CAN_RTR_FLAG;
> @@ -871,15 +859,15 @@ static int pch_can_rx_normal(struct net_device *n=
dev, u32 int_stat)
>  		stats->rx_bytes +=3D cf->can_dlc;
> =20
>  		if (k < PCH_FIFO_THRESH) {
> -			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL |
> -				  CAN_CMASK_ARB, &priv->regs->if1_cmask);
> +			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL |
> +				  PCH_CMASK_ARB, &priv->regs->if1_cmask);
> =20
>  			/* Clearing the Dir bit. */
> -			pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID2_DIR);
> +			pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID2_DIR);
> =20
>  			/* Clearing NewDat & IntPnd */
>  			pch_can_bit_clear(&priv->regs->if1_mcont,
> -					  CAN_IF_MCONT_INTPND);
> +					  PCH_IF_MCONT_INTPND);
>  			pch_can_check_if_busy(&priv->regs->if1_creq, k);
>  		} else if (k > PCH_FIFO_THRESH) {
>  			pch_can_int_clr(priv, k);
> @@ -890,7 +878,7 @@ static int pch_can_rx_normal(struct net_device *nde=
v, u32 int_stat)
>  		}
>  RX_NEXT:
>  		/* Reading the messsage object from the Message RAM */
> -		iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
>  		pch_can_check_if_busy(&priv->regs->if1_creq, k + 1);
>  		reg =3D ioread32(&priv->regs->if1_mcont);
>  	}
> @@ -913,7 +901,7 @@ static int pch_can_rx_poll(struct napi_struct *napi=
, int quota)
>  		return 0;
> =20
>  INT_STAT:
> -	if (int_stat =3D=3D CAN_STATUS_INT) {
> +	if (int_stat =3D=3D PCH_STATUS_INT) {
>  		reg_stat =3D ioread32(&priv->regs->stat);
>  		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
>  			if ((reg_stat & PCH_LEC_ALL) !=3D PCH_LEC_ALL)
> @@ -922,7 +910,7 @@ INT_STAT:
> =20
>  		if (reg_stat & PCH_TX_OK) {
>  			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -			iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> +			iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
>  			pch_can_check_if_busy(&priv->regs->if2_creq,
>  					       ioread32(&priv->regs->intr));
>  			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> @@ -933,7 +921,7 @@ INT_STAT:
>  			pch_can_bit_clear(&priv->regs->stat, PCH_RX_OK);
> =20
>  		int_stat =3D pch_can_int_pending(priv);
> -		if (int_stat =3D=3D CAN_STATUS_INT)
> +		if (int_stat =3D=3D PCH_STATUS_INT)
>  			goto INT_STAT;
>  	}
> =20
> @@ -945,14 +933,14 @@ MSG_OBJ:
>  		if (rcv_pkts < 0)
>  			return 0;
>  	} else if ((int_stat > PCH_RX_OBJ_NUM) && (int_stat <=3D PCH_OBJ_NUM)=
) {
> -		if (priv->msg_obj[int_stat - 1] =3D=3D MSG_OBJ_TX) {
> +		if (priv->msg_obj[int_stat - 1] =3D=3D PCH_MSG_OBJ_TX) {
>  			/* Handle transmission interrupt */
>  			can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_NUM - 1);
>  			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -			iowrite32(CAN_CMASK_RX_TX_GET | CAN_CMASK_CLRINTPND,
> +			iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
>  				  &priv->regs->if2_cmask);
>  			dlc =3D ioread32(&priv->regs->if2_mcont) &
> -				       CAN_IF_MCONT_DLC;
> +				       PCH_IF_MCONT_DLC;
>  			pch_can_check_if_busy(&priv->regs->if2_creq, int_stat);
>  			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>  			if (dlc > 8)
> @@ -963,7 +951,7 @@ MSG_OBJ:
>  	}
> =20
>  	int_stat =3D pch_can_int_pending(priv);
> -	if (int_stat =3D=3D CAN_STATUS_INT)
> +	if (int_stat =3D=3D PCH_STATUS_INT)
>  		goto INT_STAT;
>  	else if (int_stat >=3D 1 && int_stat <=3D 32)
>  		goto MSG_OBJ;
> @@ -983,17 +971,17 @@ static int pch_set_bittiming(struct net_device *n=
dev)
>  	u32 brp;
> =20
>  	/* Setting the CCE bit for accessing the Can Timing register. */
> -	pch_can_bit_set(&priv->regs->cont, CAN_CTRL_CCE);
> +	pch_can_bit_set(&priv->regs->cont, PCH_CTRL_CCE);
> =20
>  	brp =3D (bt->tq) / (1000000000/PCH_CAN_CLK) - 1;
> -	canbit =3D brp & MSK_BITT_BRP;
> -	canbit |=3D (bt->sjw - 1) << BIT_BITT_SJW;
> -	canbit |=3D (bt->phase_seg1 + bt->prop_seg - 1) << BIT_BITT_TSEG1;
> -	canbit |=3D (bt->phase_seg2 - 1) << BIT_BITT_TSEG2;
> -	bepe =3D (brp & MSK_BRPE_BRPE) >> BIT_BRPE_BRPE;
> +	canbit =3D brp & PCH_MSK_BITT_BRP;
> +	canbit |=3D (bt->sjw - 1) << PCH_BIT_SJW;
> +	canbit |=3D (bt->phase_seg1 + bt->prop_seg - 1) << PCH_BIT_TSEG1;
> +	canbit |=3D (bt->phase_seg2 - 1) << PCH_BIT_TSEG2;
> +	bepe =3D (brp & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE;
>  	iowrite32(canbit, &priv->regs->bitt);
>  	iowrite32(bepe, &priv->regs->brpe);
> -	pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_CCE);
> +	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_CCE);
> =20
>  	return 0;
>  }
> @@ -1137,19 +1125,19 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb=
, struct net_device *ndev)
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> =20
>  	/* Reading the Msg Obj from the Msg RAM to the Interface register. */=

> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
>  	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
> =20
>  	/* Setting the CMASK register. */
> -	pch_can_bit_set(&priv->regs->if2_cmask, CAN_CMASK_ALL);
> +	pch_can_bit_set(&priv->regs->if2_cmask, PCH_CMASK_ALL);
> =20
>  	/* If ID extended is set. */
>  	pch_can_bit_clear(&priv->regs->if2_id1, 0xffff);
> -	pch_can_bit_clear(&priv->regs->if2_id2, 0x1fff | CAN_ID2_XTD);
> +	pch_can_bit_clear(&priv->regs->if2_id2, 0x1fff | PCH_ID2_XTD);
>  	if (cf->can_id & CAN_EFF_FLAG) {
>  		pch_can_bit_set(&priv->regs->if2_id1, cf->can_id & 0xffff);
>  		pch_can_bit_set(&priv->regs->if2_id2,
> -				((cf->can_id >> 16) & 0x1fff) | CAN_ID2_XTD);
> +				((cf->can_id >> 16) & 0x1fff) | PCH_ID2_XTD);
>  	} else {
>  		pch_can_bit_set(&priv->regs->if2_id1, 0);
>  		pch_can_bit_set(&priv->regs->if2_id2,
> @@ -1158,7 +1146,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, =
struct net_device *ndev)
> =20
>  	/* If remote frame has to be transmitted.. */
>  	if (cf->can_id & CAN_RTR_FLAG)
> -		pch_can_bit_clear(&priv->regs->if2_id2, CAN_ID2_DIR);
> +		pch_can_bit_clear(&priv->regs->if2_id2, PCH_ID2_DIR);
> =20
>  	for (i =3D 0, j =3D 0; i < cf->can_dlc; j++) {
>  		iowrite32(le32_to_cpu(cf->data[i++]),
> @@ -1177,12 +1165,12 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb=
, struct net_device *ndev)
> =20
>  	/* Clearing IntPend, NewDat & TxRqst */
>  	pch_can_bit_clear(&priv->regs->if2_mcont,
> -			  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND |
> -			  CAN_IF_MCONT_TXRQXT);
> +			  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
> +			  PCH_IF_MCONT_TXRQXT);
> =20
>  	/* Setting NewDat, TxRqst bits */
>  	pch_can_bit_set(&priv->regs->if2_mcont,
> -			CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_TXRQXT);
> +			PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT);
> =20
>  	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
> =20
> @@ -1245,7 +1233,7 @@ static int pch_can_suspend(struct pci_dev *pdev, =
pm_message_t state)
> =20
>  	/* Save Tx buffer enable state */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX)
> +		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX)
>  			pch_can_get_tx_enable(priv, i + 1,
>  					      &(priv->tx_enable[i]));
>  	}
> @@ -1255,7 +1243,7 @@ static int pch_can_suspend(struct pci_dev *pdev, =
pm_message_t state)
> =20
>  	/* Save Rx buffer enable state */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX) {
> +		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_RX) {
>  			pch_can_get_rx_enable(priv, i + 1,
>  						&(priv->rx_enable[i]));
>  			pch_can_get_rx_buffer_link(priv, i + 1,
> @@ -1313,7 +1301,7 @@ static int pch_can_resume(struct pci_dev *pdev)
> =20
>  	/* Enabling the transmit buffer. */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX) {
> +		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX) {
>  			pch_can_set_tx_enable(priv, i + 1,
>  					      priv->tx_enable[i]);
>  		}
> @@ -1321,7 +1309,7 @@ static int pch_can_resume(struct pci_dev *pdev)
> =20
>  	/* Configuring the receive buffer and enabling them. */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX) {
> +		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_RX) {
>  			/* Restore buffer link */
>  			pch_can_set_rx_buffer_link(priv, i + 1,
>  						   priv->rx_link[i]);
> @@ -1349,8 +1337,8 @@ static int pch_can_get_berr_counter(const struct =
net_device *dev,
>  {
>  	struct pch_can_priv *priv =3D netdev_priv(dev);
> =20
> -	bec->txerr =3D ioread32(&priv->regs->errc) & CAN_TEC;
> -	bec->rxerr =3D (ioread32(&priv->regs->errc) & CAN_REC) >> 8;
> +	bec->txerr =3D ioread32(&priv->regs->errc) & PCH_TEC;
> +	bec->rxerr =3D (ioread32(&priv->regs->errc) & PCH_REC) >> 8;
> =20
>  	return 0;
>  }
> @@ -1410,10 +1398,10 @@ static int __devinit pch_can_probe(struct pci_d=
ev *pdev,
> =20
>  	priv->can.clock.freq =3D PCH_CAN_CLK; /* Hz */
>  	for (index =3D 0; index < PCH_RX_OBJ_NUM;)
> -		priv->msg_obj[index++] =3D MSG_OBJ_RX;
> +		priv->msg_obj[index++] =3D PCH_MSG_OBJ_RX;
> =20
>  	for (index =3D index;  index < PCH_OBJ_NUM;)
> -		priv->msg_obj[index++] =3D MSG_OBJ_TX;
> +		priv->msg_obj[index++] =3D PCH_MSG_OBJ_TX;
> =20
>  	netif_napi_add(ndev, &priv->napi, pch_can_rx_poll, PCH_RX_OBJ_NUM);
> =20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig4826C95ADCF306F735458579
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzjnIAACgkQjTAFq1RaXHOkNQCdFv1LQT8kgYgNTPQimRndp2bT
K/kAn21zhShwJWmYN1XyoDEaoJqIZi1V
=iUdJ
-----END PGP SIGNATURE-----

--------------enig4826C95ADCF306F735458579--
