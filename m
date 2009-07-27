From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: logging sizeof(struct ip_vs_conn) on startup
Date: Mon, 27 Jul 2009 19:22:23 +1000
Message-ID: <20090727092219.GB26337@verge.net.au>
References: <20090727090741.16509.35291.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lvs-users@linuxvirtualserver.org,
	malcolm@loadbalancer.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Hannes Eder <heder@google.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755874AbZG0JW0@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090727090741.16509.35291.stgit@jazzy.zrh.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2009 at 11:08:34AM +0200, Hannes Eder wrote:
> No more guessing, how much memory is used by IPVS for a connection.

I like that.

> Signed-off-by: Hannes Eder <heder@google.com>

Signed-off-by: Simon Horman <horms@verge.net.au>

> ---
>  net/netfilter/ipvs/ip_vs_core.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index b021464..5b0997c 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1475,7 +1475,8 @@ static int __init ip_vs_init(void)
>  		goto cleanup_conn;
>  	}
>  
> -	IP_VS_INFO("ipvs loaded.\n");
> +	IP_VS_INFO("ipvs loaded (using %Zd bytes/connection).\n",
> +	       sizeof(struct ip_vs_conn));
>  	return ret;
>  
>    cleanup_conn:
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
