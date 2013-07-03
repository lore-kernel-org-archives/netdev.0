From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 0/3] make cdc_ncm_tx_fixup and cdc_ncm_rx_fixup non-static functions
Date: Wed, 03 Jul 2013 09:45:59 +0200
Message-ID: <8761wsw0g8.fsf@nemi.mork.no>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
	<87wqp9xja5.fsf@nemi.mork.no>
	<alpine.LNX.2.02.1307021855270.19053@eeeadesso>
	<alpine.LNX.2.02.1307022202570.26010@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51799 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753960Ab3GCHqC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 03:46:02 -0400
In-Reply-To: <alpine.LNX.2.02.1307022202570.26010@eeeadesso> (Enrico Mioso's
	message of "Tue, 2 Jul 2013 22:06:18 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> Let cdc_ncm_tx_fixup and cdc_ncm_rx_fixup be non-static
>
> This patchs makes those functions non-static, so that they could be e=
xported=20
> for use by other drivers.
>
> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
>
>
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 43afde8..493277e 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -858,7 +858,7 @@ static void cdc_ncm_txpath_bh(unsigned long param=
)
>  	}
>  }
> =20
> -static struct sk_buff *
> +struct sk_buff *
>  cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flag=
s)
>  {
>  	struct sk_buff *skb_out;
> @@ -965,7 +965,7 @@ error:
>  }
>  EXPORT_SYMBOL_GPL(cdc_ncm_rx_verify_ndp16);
> =20
> -static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_=
in)
> +int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
>  {
>  	struct sk_buff *skb;
>  	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
>


This should be part of patch #1.  And there is no patch #0 in any case.
Part 0 is only for describing the whole series - motivation, design
choices, changes between versions etc.




Bj=C3=B8rn
