From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPSEC]: Add ICMP host relookup support
Date: Tue, 11 Dec 2007 09:10:56 -0800 (PST)
Message-ID: <20071211.091056.161097349.davem@davemloft.net>
References: <20071211165317.GA16420@gondor.apana.org.au>
	<E1J28Nq-0004IU-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752027AbXLKRK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 12:10:57 -0500
In-Reply-To: <E1J28Nq-0004IU-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 12 Dec 2007 00:55:02 +0800

> diff --git a/include/net/dst.h b/include/net/dst.h
> index aaa2dbb..31468c9 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -268,6 +268,7 @@ extern void		dst_init(void);
>  /* Flags for xfrm_lookup flags argument. */
>  enum {
>  	XFRM_LOOKUP_WAIT = 1 << 0,
> +	XFRM_LOOKUP_ICMP = 1 << 1,
>  };
>  
>  struct flowi;

This enumeration doesn't exist in my tree, what are you generating
these patches against?

I'm even reverting the first patch for now until this is figured out.
