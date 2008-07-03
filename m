From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Fix inter family IPsec tunnel handling again
Date: Thu, 3 Jul 2008 17:05:22 +0800
Message-ID: <20080703090522.GB27923@gondor.apana.org.au>
References: <20080703085542.GJ9549@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58971 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760137AbYGCNzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 09:55:07 -0400
Content-Disposition: inline
In-Reply-To: <20080703085542.GJ9549@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2008 at 10:55:42AM +0200, Steffen Klassert wrote:
>
> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> +        case IPPROTO_IPV6:
> +                if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
> +                        goto out;
> +                break;
> +#endif

This is supposed to use protocol-agnostic data so why do you need
the ifdef?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
