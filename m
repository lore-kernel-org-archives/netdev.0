From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: neigh_create/inetdev_destroy race?
Date: Thu, 2 Sep 2004 23:06:05 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040902130605.GA32570@gondor.apana.org.au>
References: <20040814013030.GA2042@gondor.apana.org.au> <20040814050848.GA11874@gondor.apana.org.au> <20040814062703.GA4806@gondor.apana.org.au> <20040815191450.77532d5d.davem@redhat.com> <20040816105131.GA11299@gondor.apana.org.au> <20040828234201.79556f6e.davem@davemloft.net> <20040829065031.GA786@gondor.apana.org.au> <20040830230820.7514985d.davem@davemloft.net> <20040831104139.GA2124@gondor.apana.org.au> <20040901222118.0ce4bcc6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040901222118.0ce4bcc6.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 01, 2004 at 10:21:18PM -0700, David S. Miller wrote:
> 
> So here's the first step.  No rcu_read_lock()'s are needed
> since the tbl->lock needs to be held as a write when
> traversing these things anyways for other reasons.

Thanks.

> Can you work on the next bit you mentioned, making
> sure the corresponding idev is still alive when we add
> a neighbour with its neigh_parms to the hash table?

Sure.  Actually I prefer to do it by ref counting neigh_parms directly.
I'll send you a patch soon.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
