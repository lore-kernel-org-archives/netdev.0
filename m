From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Fri, 13 May 2005 08:10:46 +1000
Message-ID: <20050512221046.GA22136@gondor.apana.org.au>
References: <20050511.223036.39664020.davem@davemloft.net> <E1DWAZg-0006aD-00@gondolin.me.apana.org.au> <20050512.131349.32715242.davem@davemloft.net> <20050512214744.GA21958@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050512214744.GA21958@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 13, 2005 at 07:47:44AM +1000, herbert wrote:
> 
> You're being frugal Dave :) I was happy with one skb_clone per
> skb and you're having problems with skb_get? :)
> 
> Seriously, we already do one skb_clone for every packet sent
> so we won't be incurring any extra overhead with this.

Nevermind, you're comparing to the existing TSO implementation.
So how big exactly is the slowdown?

> > A secondary point is that I'd like to use a name other than
> > NETIF_F_FRAGLIST because people are super confused as to what this
> > device flag even means.  Some people confuse it with NETIF_F_SG,
> > others thing it takes a huge UDP frame and fragments it into MTU sized
> > IP frames and checksums the whole thing.  None of which are true.
> 
> Fine by me.  But you know I'm not good with names :)

This just occured to me, what about NETIF_F_SKBLIST?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
