From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV6] Fix memory leaks in TCP error path
Date: Sat, 6 Nov 2004 11:31:07 +1100
Message-ID: <20041106003107.GA14649@gondor.apana.org.au>
References: <20041105084904.GA8253@gondor.apana.org.au> <20041105161820.5c9bd53b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041105161820.5c9bd53b.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 05, 2004 at 04:18:20PM -0800, David S. Miller wrote:
> 
> This patch actually adds a leak with the way xfrm_lookup() is currently
> coded.
>
> This means that to cover all cases you have to have the dst_release()
> there in that "if (xfrm_lookup()<0)" code path in order to handle
> case #2 above.

Not quite.  kfree_skb will release the dst for you.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
