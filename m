From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Set TTL from route
Date: Tue, 24 Aug 2004 11:47:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824114708.729c5355.davem@redhat.com>
References: <20040824105641.GA10202@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040824105641.GA10202@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2004 20:56:41 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is the promised patch that sets the TTL from the route parameter.
> I decided against adding an option to inherit the TTL like IPIP/GRE
> as I think that it doesn't really make sense with IPsec.  But it
> can be easily added later if someone needs it.

I think we want to add this at some point.

> This isn't completely right when nested tunnels are involved.  The
> TTL for intervening tunnels should be set from the routes to the
> intervening nodes.  But fixing that involves using information that
> isn't currently in the bundle.  I'll revisit this once the MTU stuff
> is fixed since that'll also involving adding the intervening routes
> to the bundle.

Looks great, patch applied.

Patrick McHardy was thinking of looking into the MTU issues
after he finished up some netfilter IPSEC patches he's been
working on.  Perhaps you can work together with him :)
