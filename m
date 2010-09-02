From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: arp: code cleanup
Date: Wed, 01 Sep 2010 17:57:12 -0700 (PDT)
Message-ID: <20100901.175712.199039832.davem@davemloft.net>
References: <1283385110-2953-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35125
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753390Ab0IBA44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 20:56:56 -0400
In-Reply-To: <1283385110-2953-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu,  2 Sep 2010 07:51:50 +0800

> Clean the code up according to Documentation/CodingStyle.
> 
> Don't initialize the variable dont_send in arp_process().
> 
> Remove the temporary varialbe flags in arp_state_to_flags().
> 
> Replace printk(KERN_DEBUG...) with pr_debug(...).
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  1 file changed, 212 insertions(+), 228 deletions(-)
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 96c1955..cbb0e7c 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -1,4 +1,5 @@
> -/* linux/net/ipv4/arp.c
> +/*
> + * linux/net/ipv4/arp.c
>   *
>   * Copyright (C) 1994 by Florian  La Roche
>   *

I do not condone comments being written this way, it wastes precious
vertical space in one's terminal window.  They should always be
written as:

	/* A comment
	 * looks like this.
	 */

in any patch you want me to apply in the networking.

And what really angers me when people touch things like that is
how later in the patch:

> @@ -258,31 +259,31 @@ static int arp_constructor(struct neighbour *neigh)
>  		neigh->output = neigh->ops->queue_xmit;
>  	} else {
>  		/* Good devices (checked by reading texts, but only Ethernet is
> -		   tested)
> -
> -		   ARPHRD_ETHER: (ethernet, apfddi)
 ...
> -		   in old paradigm.
> +		 * tested)
> +		 *
> +		 * ARPHRD_ETHER: (ethernet, apfddi)

you go and apply COMPLETELY INCONSISTENT changes to other comemnts.

Leave the comments alone, thanks.
