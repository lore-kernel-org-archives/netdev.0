From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: restore multicast rx filter on resume
Date: Mon, 26 Dec 2011 15:17:54 -0500 (EST)
Message-ID: <20111226.151754.417402855307646295.davem@davemloft.net>
References: <20111225081833.GC3088@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: florz@florz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab1LZUTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 15:19:05 -0500
In-Reply-To: <20111225081833.GC3088@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Zumbiehl <florz@florz.de>
Date: Sun, 25 Dec 2011 09:18:33 +0100

> skge: restore multicast rx filter on resume
>     
> Signed-off-by: Florian Zumbiehl <florz@florz.de>

Stephen?  This one looks fine to me.

> diff --git a/drivers/net/skge.c b/drivers/net/skge.c
> index f4be5c7..cd968e5 100644
> --- a/drivers/net/skge.c
> +++ b/drivers/net/skge.c
> @@ -4046,6 +4046,7 @@ static int skge_resume(struct device *dev)
>  				dev_close(dev);
>  				goto out;
>  			}
> +			skge_set_multicast(dev);
>  		}
>  	}
>  out:
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
