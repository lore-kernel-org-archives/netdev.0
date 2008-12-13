From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/8] net: Add frag_list support to skb_segment
Date: Sat, 13 Dec 2008 14:20:22 +1100
Message-ID: <20081213032022.GB14324@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cv-0000qk-Ec@gondolin.me.apana.org.au> <20081212194618.GA27281@ioremap.net> <20081212214125.GA11046@gondor.apana.org.au> <20081213023855.GA807@ioremap.net> <20081213024305.GA14056@gondor.apana.org.au> <20081213031110.GF807@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60759 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753112AbYLMDU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 22:20:27 -0500
Content-Disposition: inline
In-Reply-To: <20081213031110.GF807@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 06:11:10AM +0300, Evgeniy Polyakov wrote:
>
> > This isn't a problem.  fskb2 is still on the original frag_list so
> > we don't need to free it if skb_clone fails.
> 
> But nskb was not added into the list or it was?

We've added it to the segs list which is freed at err:.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
