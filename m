From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Sun, 3 Apr 2005 17:43:37 +1000
Message-ID: <20050403074337.GA8083@gondor.apana.org.au>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au> <424E641A.1020609@cosmosbay.com> <16974.41648.568927.54429@robur.slu.se> <20050402193224.GA25157@gondor.apana.org.au> <20050402115528.11f71a3c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert.Olsson@data.slu.se, dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050402115528.11f71a3c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Apr 02, 2005 at 11:55:28AM -0800, David S. Miller wrote:
> 
> I think we should, in the short term, increase the secret interval
> where it exists in the tree (netfilter conntrack is another instance
> for example).

We could also move rt_cache_flush into a kernel thread.  When the
number of chains is large this function is really expensive for a
softirq handler.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
