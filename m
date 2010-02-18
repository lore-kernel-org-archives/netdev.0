From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/12] tg3: Enforce DMA mapping / skb
 assignment ordering
Date: Wed, 17 Feb 2010 17:27:05 -0800 (PST)
Message-ID: <20100217.172705.99297322.davem@davemloft.net>
References: <1266455825-16150-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38511
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752108Ab0BRB0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 20:26:49 -0500
In-Reply-To: <1266455825-16150-2-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 17 Feb 2010 17:16:54 -0800


You're providing the patch twice here:

> ---
>  drivers/net/tg3.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 385434f..344490e 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -4659,11 +4659,16 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 ...
> --
> 1.6.4.4
 ...
> ---
>  drivers/net/tg3.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 385434f..344490e 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -4659,11 +4659,16 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)

I'll fix this up but please make amends to ensure this doesn't
happen again.
