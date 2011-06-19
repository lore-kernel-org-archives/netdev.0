From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 06/11] macb: enable transmit time stamping.
Date: Sun, 19 Jun 2011 13:56:40 +0200
Message-ID: <1308484600.3539.74.camel@edumazet-laptop>
References: <cover.1308481491.git.richard.cochran@omicron.at>
	 <ac8adf65aecd78e714a172a30a0b455e3a12dec9.1308481492.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54703 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485Ab1FSL4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:56:50 -0400
Received: by mail-wy0-f174.google.com with SMTP id 38so1117409wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:56:49 -0700 (PDT)
In-Reply-To: <ac8adf65aecd78e714a172a30a0b455e3a12dec9.1308481492.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 19 juin 2011 =C3=A0 13:20 +0200, Richard Cochran a =C3=A9cr=
it :
> This patch enables software (and phy device) transmit time stamping
> Compile tested only.
>=20
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  drivers/net/macb.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> index 6c6a028..6944478 100644
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
> @@ -676,6 +676,8 @@ static int macb_start_xmit(struct sk_buff *skb, s=
truct net_device *dev)
> =20
>  	spin_unlock_irqrestore(&bp->lock, flags);
> =20
> +	skb_tx_timestamp(skb);
> +
>  	return NETDEV_TX_OK;
>  }
> =20

Same problem here, its not safe.



