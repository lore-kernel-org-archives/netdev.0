From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IP6IP6] Handle ECN correctly
Date: Thu, 9 Sep 2004 14:54:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909045415.GA20079@gondor.apana.org.au>
References: <20040909034508.GA19547@gondor.apana.org.au> <20040908214023.08dec350.davem@davemloft.net> <20040909044336.GA19999@gondor.apana.org.au> <20040908214926.51b56a66.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040908214926.51b56a66.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 08, 2004 at 09:49:26PM -0700, David S. Miller wrote:
> 
> We were going to make all the ipv4 tunnels offer encapsulation
> behavior for these fields that matched the two major models
> of behavior described in the IP tunneling RFCs.
> 
> Specifically I'm talking about the Uniform and the Pipe model
> described in RFC-2983.

You mean the TOS field?

> I would expect a change for that to occur in net/ipv4/ipip.c
> or similar. :)

OK, I'll take a look at this.  I presume that the TOS options
in ip6tunnel.c is to your liking?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
