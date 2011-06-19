From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 07/11] fs_enet: enable transmit time stamping.
Date: Sun, 19 Jun 2011 13:58:04 +0200
Message-ID: <1308484684.3539.76.camel@edumazet-laptop>
References: <cover.1308481491.git.richard.cochran@omicron.at>
	 <2a8677b99c6b8d0e34bbf0f6d6a44e6c7992636d.1308481492.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37369 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693Ab1FSL6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:58:14 -0400
Received: by wyb38 with SMTP id 38so1117876wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:58:13 -0700 (PDT)
In-Reply-To: <2a8677b99c6b8d0e34bbf0f6d6a44e6c7992636d.1308481492.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 19 juin 2011 =C3=A0 13:20 +0200, Richard Cochran a =C3=A9cr=
it :
> This patch enables software (and phy device) transmit time stamping.
> Compile tested only.
>=20
> Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>
> Cc: Vitaly Bordug <vbordug@ru.mvista.com>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  drivers/net/fs_enet/fs_enet-main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet=
/fs_enet-main.c
> index 21abb5c..8dcb272 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -701,6 +701,8 @@ static int fs_enet_start_xmit(struct sk_buff *skb=
, struct net_device *dev)
> =20
>  	spin_unlock_irqrestore(&fep->tx_lock, flags);
> =20
> +	skb_tx_timestamp(skb);
> +
>  	return NETDEV_TX_OK;
>  }
> =20

Well, I'll stop my review here, there is the same problem I guess in al=
l
your patches.


