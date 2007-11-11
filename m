From: Simon Horman <horms@verge.net.au>
Subject: Re: [2.6 patch] net/ipv4/ipvs/: remove unused exports
Date: Sun, 11 Nov 2007 16:09:40 +0900
Message-ID: <20071111070939.GA25304@verge.net.au>
References: <20071111064840.GJ21669@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rumen G. Bogdanovski" <rumen@voicecho.com>, wensong@linux-vs.org,
	ja@ssi.bg, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	LVS Development mailing list
	<lvs-devel@linuxvirtualserver.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:32841 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751451AbXKKI0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2007 03:26:53 -0500
Content-Disposition: inline
In-Reply-To: <20071111064840.GJ21669@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 11, 2007 at 07:48:40AM +0100, Adrian Bunk wrote:
> This patch removes the following unused EXPORT_SYMBOL's:
> - ip_vs_try_bind_dest
> - ip_vs_find_dest
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Looks fine to me.

Should Dave Miller put this in his tree,
or do you want to handle it a different way?

Acked-by: Simon Horman <horms@verge.net.au>

> 
> ---
> 
>  net/ipv4/ipvs/ip_vs_conn.c |    1 -
>  net/ipv4/ipvs/ip_vs_ctl.c  |    1 -
>  2 files changed, 2 deletions(-)
> 
> ad9f400d4f66ea3423f97e609d6ef2572055c603 
> diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
> index b7eeae6..0a9f3c3 100644
> --- a/net/ipv4/ipvs/ip_vs_conn.c
> +++ b/net/ipv4/ipvs/ip_vs_conn.c
> @@ -441,7 +441,6 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
>  	} else
>  		return NULL;
>  }
> -EXPORT_SYMBOL(ip_vs_try_bind_dest);
>  
>  
>  /*
> diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
> index 3c4d22a..b64cf45 100644
> --- a/net/ipv4/ipvs/ip_vs_ctl.c
> +++ b/net/ipv4/ipvs/ip_vs_ctl.c
> @@ -604,7 +604,6 @@ struct ip_vs_dest *ip_vs_find_dest(__be32 daddr, __be16 dport,
>  	ip_vs_service_put(svc);
>  	return dest;
>  }
> -EXPORT_SYMBOL(ip_vs_find_dest);
>  
>  /*
>   *  Lookup dest by {svc,addr,port} in the destination trash.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

