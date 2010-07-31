From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: Fixes a typo from "dev" to "ndev" that caused
 compilation erros.
Date: Fri, 30 Jul 2010 22:20:34 -0700 (PDT)
Message-ID: <20100730.222034.183058824.davem@davemloft.net>
References: <AANLkTiko540hMAUhaJr5mNKzFK2-vBOTZmEOxZWZv7ci@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chaithrika@ti.com, srk@ti.com, khilman@deeprootsystems.com,
	jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, segooon@gmail.com
To: henrique.camargo@ensitec.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51263
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751032Ab0GaFUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 01:20:16 -0400
In-Reply-To: <AANLkTiko540hMAUhaJr5mNKzFK2-vBOTZmEOxZWZv7ci@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henrique Camargo <henrique.camargo@ensitec.com.br>
Date: Thu, 29 Jul 2010 12:51:49 -0300

> From: Henrique Camargo

>From lines need valid email addresses.  But in this case since you
are the person who wrote the patch, adding another From: tag in
the message body is superfluous and you can just omit it.

> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 25e14d2..b89b7bf 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -1182,8 +1182,8 @@ static int emac_net_tx_complete(struct emac_priv *priv,
>         struct net_device *ndev = priv->ndev;
>         u32 cnt;
> 
> -       if (unlikely(num_tokens && netif_queue_stopped(dev)))
> -               netif_start_queue(dev);
> +       if (unlikely(num_tokens && netif_queue_stopped(ndev)))
> +               netif_start_queue(ndev);

Your patch is corrupted, tab characters have been turned into spaces by
your email client.

This makes your patch unusable.

Please fix up these errors and resubmit your patch.

Thank you.
