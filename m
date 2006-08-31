From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: LRO fix needed
Date: Fri, 1 Sep 2006 09:43:48 +1000
Message-ID: <20060831234347.GA7843@gondor.apana.org.au>
References: <20060831.164227.71090271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ananda.Raju@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:273 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S932379AbWHaXoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 19:44:05 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060831.164227.71090271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2006 at 04:42:27PM -0700, David Miller wrote:
> 
> So could you please make the S2io driver LRO path
> set skb_shared_info(skb)->gso_size appropriately?
> Probably the easiest is to use the length of the
> first frag of a multiple frag LRO sequence.

It might be better to set it to the biggest frag you see rather
than the first.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
