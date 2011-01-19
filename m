From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 18/79] IPVS: Remove useless { } block from
 ip_vs_process_message()
Date: Wed, 19 Jan 2011 11:40:52 -0800
Message-ID: <1295466052.1952.29.camel@Joe-Laptop>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
	 <1295464519-21763-19-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-19-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-01-19 at 20:14 +0100, kaber@trash.net wrote:
> From: Simon Horman <horms@verge.net.au>
>  net/netfilter/ipvs/ip_vs_sync.c |   24 +++++++++++-------------
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -381,20 +381,18 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
>  			}
>  		}
>  
> -		{
> -			if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
> -					      (union nf_inet_addr *)&s->caddr,
> -					      s->cport,
> -					      (union nf_inet_addr *)&s->vaddr,
> -					      s->vport, &param)) {
> -				pr_err("ip_vs_conn_fill_param_sync failed");
> -				return;
> -			}
> -			if (!(flags & IP_VS_CONN_F_TEMPLATE))
> -				cp = ip_vs_conn_in_get(&param);
> -			else
> -				cp = ip_vs_ct_in_get(&param);
> +		if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
> +					       (union nf_inet_addr *)&s->caddr,
> +					       s->cport,
> +					       (union nf_inet_addr *)&s->vaddr,
> +					       s->vport, &param)) {
> +			pr_err("ip_vs_conn_fill_param_sync failed");

The original and this pr_err is missing a \n before close quote.


