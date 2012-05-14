From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/6] netfilter: decnet: switch hook PFs to nfproto
Date: Mon, 14 May 2012 16:45:43 +0200
Message-ID: <20120514144543.GF12992@1984>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
 <1337003799-2517-2-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337003799-2517-2-git-send-email-alban.crequy@collabora.co.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

@Jan,

I remember you introduced all this NFPROTO_* thing time ago.

Any complain on this patchset?

Thanks.

On Mon, May 14, 2012 at 02:56:35PM +0100, Alban Crequy wrote:
> NFPROTO_* constants were usually equal to PF_* constants but it is not
> necessary and it will waste less memory if we don't do so (see commit 7e9c6e
> "netfilter: Introduce NFPROTO_* constants")
> 
> Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
> Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
> ---
>  net/decnet/netfilter/dn_rtmsg.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
> index 1531135..7fb7250 100644
> --- a/net/decnet/netfilter/dn_rtmsg.c
> +++ b/net/decnet/netfilter/dn_rtmsg.c
> @@ -118,7 +118,7 @@ static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
>  
>  static struct nf_hook_ops dnrmg_ops __read_mostly = {
>  	.hook		= dnrmg_hook,
> -	.pf		= PF_DECnet,
> +	.pf		= NFPROTO_DECNET,
>  	.hooknum	= NF_DN_ROUTE,
>  	.priority	= NF_DN_PRI_DNRTMSG,
>  };
> -- 
> 1.7.2.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
