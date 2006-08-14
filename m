From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_shared_info()
Date: Mon, 14 Aug 2006 17:29:03 +1000
Message-ID: <20060814072903.GA14138@gondor.apana.org.au>
References: <20060808.163915.03600382.davem@davemloft.net> <200608140704.01533.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53261 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751913AbWHNH3S
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 03:29:18 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200608140704.01533.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2006 at 07:04:01AM +0200, Andi Kleen wrote:
> 
> Another reason to move it in the sk_buff would be better cache 
> coloring? Currently on large/small MTU packets it will be always on 
> the same colors.

If we went with a fully paged skbs this should be a non-issue, right?

In a fully paged representation the head would be small which is the
perfect place to place the skb_shared_info.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
