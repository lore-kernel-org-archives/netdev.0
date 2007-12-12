From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [IPSEC]: Add ICMP host relookup support
Date: Wed, 12 Dec 2007 10:45:16 -0800 (PST)
Message-ID: <20071212.104516.111707350.davem@davemloft.net>
References: <20071212012552.GA20618@gondor.apana.org.au>
	<E1J2GrJ-0005Se-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757462AbXLLSpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 13:45:17 -0500
In-Reply-To: <E1J2GrJ-0005Se-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 12 Dec 2007 09:58:01 +0800

> [IPSEC]: Add ICMP host relookup support
> 
> RFC 4301 requires us to relookup ICMP traffic that does not match any
> policies using the reverse of its payload.  This patch implements this
> for ICMP traffic that originates from or terminates on localhost.
> 
> This is activated on outbound with the new policy flag XFRM_POLICY_ICMP,
> and on inbound by the new state flag XFRM_STATE_ICMP.
> 
> On inbound the policy check is now performed by the ICMP protocol so
> that it can repeat the policy check where necessary.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
 ...
> @@ -268,6 +268,7 @@ extern void		dst_init(void);
>  /* Flags for xfrm_lookup flags argument. */
>  enum {
>  	XFRM_LOOKUP_WAIT = 1 << 0,
> +	XFRM_LOOKUP_ICMP = 1 << 1,
>  };
>  
>  struct flowi;

Sigh :-(  Applied.
