From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Netfilter+IPsec
Date: Fri, 25 Mar 2005 13:53:49 +1100
Message-ID: <20050325025349.GA24252@gondor.apana.org.au>
References: <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au> <20050318091129.GA28658@gondor.apana.org.au> <20050318104013.57d65e99.davem@davemloft.net> <423D9ADA.6050407@trash.net> <20050322194910.6a9fa3a4.davem@davemloft.net> <4240EA78.5050402@trash.net> <42424AAE.9080403@trash.net> <20050323214340.70a1c950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050323214340.70a1c950.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 23, 2005 at 09:43:40PM -0800, David S. Miller wrote:
> On Thu, 24 Mar 2005 06:05:50 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > This patch (not entirely reviewed myself yet) contains the parts
> > necessary for hooking output IPsec packets for netfilter.
> 
> This is actually much cleaner than I had ever anticipated.
> I like it.

I completely agree.  The output patch is an elegant piece of work.

> I suppose the input side will be quite a bit more involved?

Maybe it won't be that bad when we actually see it :)

BTW Patrick, what about the other bits in your original patch set?
In particular, have you still got the bit that does policy lookups
after SNAT?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
