From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IP6IP6] Handle ECN correctly
Date: Fri, 10 Sep 2004 10:31:58 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910003158.GA25335@gondor.apana.org.au>
References: <20040909034508.GA19547@gondor.apana.org.au> <20040908214023.08dec350.davem@davemloft.net> <20040909044336.GA19999@gondor.apana.org.au> <20040908214926.51b56a66.davem@davemloft.net> <20040909045415.GA20079@gondor.apana.org.au> <20040908220802.1c25b806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040908220802.1c25b806.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 08, 2004 at 10:08:02PM -0700, David S. Miller wrote:
> 
> > > I would expect a change for that to occur in net/ipv4/ipip.c
> > > or similar. :)
> > 
> > OK, I'll take a look at this.  I presume that the TOS options
> > in ip6tunnel.c is to your liking?
> 
> It looks fine.

Hmm, perhaps I'm still confused.  But it seems that the ability to
set the TOS to any value other than *1 is already there for ipip/ip_gre.

That feature is missing for SIT and IPsec though.

We may also want to use the TOS value from parms to decide whether we want
to encapsulate/decapsulate ECN.

Is my understanding correct?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
