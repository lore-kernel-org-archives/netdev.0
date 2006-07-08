From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Xen-devel] kernel BUG at net/core/dev.c:1133!
Date: Sat, 8 Jul 2006 12:04:45 +1000
Message-ID: <20060708020444.GB9746@gondor.apana.org.au>
References: <E1FyrUg-0003FA-00@gondolin.me.apana.org.au> <44AEBEB0.8020704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Petersson, Mats" <Mats.Petersson@amd.com>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43530 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932482AbWGHCEx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 22:04:53 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44AEBEB0.8020704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2006 at 10:06:08PM +0200, Patrick McHardy wrote:
> 
> Are you refering to this code in ip_nat_fn()?
> 
>         /* If we had a hardware checksum before, it's now invalid */
>         if ((*pskb)->ip_summed == CHECKSUM_HW)
>                 if (skb_checksum_help(*pskb, (out == NULL)))
>                         return NF_DROP;

Yep that's the one.

> Doing incremental updates should work fine. This is something
> I wanted to take care of at some point, but didn't get to it
> yet.

No worries.  I'm going to do a workaround to fix the checksums in
GSO for now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
