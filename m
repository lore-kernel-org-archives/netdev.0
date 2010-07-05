From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: Possible bug in net/ipv4/route.c?
Date: Mon, 5 Jul 2010 21:22:45 +0800
Message-ID: <20100705132245.GA6876@gondor.apana.org.au>
References: <20100705120617.GA6267@gondor.apana.org.au> <1278334754.2877.173.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1278334754.2877.173.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 05, 2010 at 02:59:14PM +0200, Eric Dumazet wrote:
>
> Why do we clear full 48 bytes skb->cb[] in skb_alloc(), if no protocol
> stack should rely it being zero ?

Unless a protocol is allocating the skb itself, then the fact
that skb_alloc clears skb->cb is no guarantee that the skb->cb
will be zero.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
