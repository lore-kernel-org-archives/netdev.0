From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_shared_info()
Date: Mon, 14 Aug 2006 17:50:45 +1000
Message-ID: <20060814075045.GA1437@gondor.apana.org.au>
References: <20060808.163915.03600382.davem@davemloft.net> <200608140704.01533.ak@suse.de> <20060814072903.GA14138@gondor.apana.org.au> <200608140945.53713.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:526 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751920AbWHNHu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 03:50:57 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200608140945.53713.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2006 at 09:45:53AM +0200, Andi Kleen wrote:
> 
> Even for 1.5k MTU? (which is still the most common case after all)

Ideally they would stay in kmalloc memory.  Could you explain the cache
colouring problem for 1500-byte packets?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
