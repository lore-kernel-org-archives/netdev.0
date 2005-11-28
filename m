From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 07/13]: [NETFILTER]: Fix xfrm lookup in
	ip_route_me_harder/ip6_route_me_harder
Date: Tue, 29 Nov 2005 08:06:28 +1100
Message-ID: <20051128210628.GA15057@gondor.apana.org.au>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163137.16666.924.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20051120163137.16666.924.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 20, 2005 at 04:31:37PM +0000, Patrick McHardy wrote:
>
> diff --git a/include/net/ip.h b/include/net/ip.h
> index 9f09882..377036b 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -45,6 +45,7 @@ struct inet_skb_parm
>  #define IPSKB_TRANSLATED	2
>  #define IPSKB_FORWARDED		4
>  #define IPSKB_XFRM_TUNNEL_SIZE	8
> +#define IPSKB_XFRM_TRANSFORMED	16
>  };

My only question about this patch is where should we clear these flags?
For instance, when ipip/gre transmits a packet, should this flag (and
perhaps other flags here) be cleared?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
