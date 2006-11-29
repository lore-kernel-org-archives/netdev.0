From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely duplicate route_reverse function
Date: Wed, 29 Nov 2006 15:38:29 +1100
Message-ID: <E1GpHDJ-00059y-00@gondolin.me.apana.org.au>
References: <20061128.202535.112619392.davem@davemloft.net>
Cc: kaber@trash.net, khc@pm.waw.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:20494 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1758785AbWK2Ei5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 23:38:57 -0500
To: davem@davemloft.net (David Miller)
In-Reply-To: <20061128.202535.112619392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 9264139..95e86ac 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -94,7 +94,9 @@ #endif
> #endif
> 
> #if !defined(CONFIG_NET_IPIP) && \
> -    !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE)
> +    !defined(CONFIG_NET_IPGRE) && \
> +    !defined(CONFIG_IPV6_SIT) && \
> +    !defined(CONFIG_IPV6_TUNNEL)
> #define MAX_HEADER LL_MAX_HEADER
> #else
> #define MAX_HEADER (LL_MAX_HEADER + 48)

What if ipip/gre are modules?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
