From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IP6IP6] Handle ECN correctly
Date: Wed, 8 Sep 2004 21:49:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908214926.51b56a66.davem@davemloft.net>
References: <20040909034508.GA19547@gondor.apana.org.au>
	<20040908214023.08dec350.davem@davemloft.net>
	<20040909044336.GA19999@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040909044336.GA19999@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004 14:43:36 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Sep 08, 2004 at 09:40:23PM -0700, David S. Miller wrote:
> > 
> > How are those TTL encap fixes coming along? ;-)
> 
> It went so well that you've already merged it :)
> 
> It's the last change on net/ipv*/xfrm*_output.c.

We were going to make all the ipv4 tunnels offer encapsulation
behavior for these fields that matched the two major models
of behavior described in the IP tunneling RFCs.

Specifically I'm talking about the Uniform and the Pipe model
described in RFC-2983.

I would expect a change for that to occur in net/ipv4/ipip.c
or similar. :)
