From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ssh server etc doesn't work anymore with net-2.6
Date: Sun, 11 Apr 2010 20:04:03 +0800
Message-ID: <20100411120403.GA20565@gondor.apana.org.au>
References: <20100411100902.GA20141@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yinghai@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100411100902.GA20141@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> After looking at the actual net-2.6 tree I see that it is actually
> CHECKSUM_PARTIAL that caused this breakage.
> 
> The fact that when this was first implemented we didn't use hw
> checksums on dataless packets might not have been an oversight
> after all.

Looks like I was too quick to blame the hardware, the synack
code can't handle CHECKSUM_PARTIAL so this is probably the real
cause.

I will send patches to fix this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
