From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IP6IP6] Handle ECN correctly
Date: Fri, 10 Sep 2004 17:02:42 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910070242.GA28017@gondor.apana.org.au>
References: <20040909034508.GA19547@gondor.apana.org.au> <20040908214023.08dec350.davem@davemloft.net> <20040909044336.GA19999@gondor.apana.org.au> <20040908214926.51b56a66.davem@davemloft.net> <20040909045415.GA20079@gondor.apana.org.au> <20040908220802.1c25b806.davem@davemloft.net> <20040910003158.GA25335@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040910003158.GA25335@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 10, 2004 at 10:31:58AM +1000, herbert wrote:
> 
> Hmm, perhaps I'm still confused.  But it seems that the ability to
> set the TOS to any value other than *1 is already there for ipip/ip_gre.
> 
> That feature is missing for SIT and IPsec though.
> 
> We may also want to use the TOS value from parms to decide whether we want
> to encapsulate/decapsulate ECN.
> 
> Is my understanding correct?

Obviously not.  Although we've got this stuff on the transmit side,
we don't do this on the receive side.

I'll look into it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
