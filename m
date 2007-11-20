From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 52/59] net/ipv4: Add missing "space"
Date: Tue, 20 Nov 2007 15:59:59 +0900
Message-ID: <20071120065958.GD10490@verge.net.au>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com> <f047768599df11a74301f81e61903c87417ea9e4.1195454436.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Networking Team <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:44529 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755034AbXKTHAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 02:00:01 -0500
Content-Disposition: inline
In-Reply-To: <f047768599df11a74301f81e61903c87417ea9e4.1195454436.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 05:53:39PM -0800, Joe Perches wrote:
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Simon Horman <horms@verge.net.au>

> ---
>  net/ipv4/ipvs/ip_vs_core.c       |    2 +-
>  net/ipv4/netfilter/iptable_raw.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
> index 20c884a..8fba202 100644
> --- a/net/ipv4/ipvs/ip_vs_core.c
> +++ b/net/ipv4/ipvs/ip_vs_core.c
> @@ -637,7 +637,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
>  	verdict = NF_DROP;
>  
>  	if (IP_VS_FWD_METHOD(cp) != 0) {
> -		IP_VS_ERR("shouldn't reach here, because the box is on the"
> +		IP_VS_ERR("shouldn't reach here, because the box is on the "
>  			  "half connection in the tun/dr module.\n");
>  	}
>  
> diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
> index 5de6e57..f867865 100644
> --- a/net/ipv4/netfilter/iptable_raw.c
> +++ b/net/ipv4/netfilter/iptable_raw.c
> @@ -66,7 +66,7 @@ ipt_local_hook(unsigned int hook,
>  	if (skb->len < sizeof(struct iphdr) ||
>  	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
>  		if (net_ratelimit())
> -			printk("iptable_raw: ignoring short SOCK_RAW"
> +			printk("iptable_raw: ignoring short SOCK_RAW "
>  			       "packet.\n");
>  		return NF_ACCEPT;
>  	}
> -- 
> 1.5.3.5.652.gf192c
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms

