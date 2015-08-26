From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v3 net-next 1/8] geneve: Initialize ethernet address in
 device setup.
Date: Wed, 26 Aug 2015 16:42:41 -0400
Message-ID: <20150826204241.GB9495@tuxdriver.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
 <1440438195-5695-2-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58061 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbbHZUpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 16:45:14 -0400
Content-Disposition: inline
In-Reply-To: <1440438195-5695-2-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 10:43:08AM -0700, Pravin B Shelar wrote:
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> Reviewed-by: Jesse Gross <jesse@nicira.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>
> ---
>  drivers/net/geneve.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index 897e1a3..95e9da0 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -297,6 +297,7 @@ static void geneve_setup(struct net_device *dev)
>  
>  	netif_keep_dst(dev);
>  	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
> +	eth_hw_addr_random(dev);
>  }
>  
>  static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
> @@ -364,9 +365,6 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
>  			return -EBUSY;
>  	}
>  
> -	if (tb[IFLA_ADDRESS] == NULL)
> -		eth_hw_addr_random(dev);
> -
>  	err = register_netdevice(dev);
>  	if (err)
>  		return err;

Acked-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
