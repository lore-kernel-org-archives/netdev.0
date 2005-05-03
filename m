From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch/RFC]: Asynchronous IPsec processing.
Date: Tue, 3 May 2005 20:14:47 +1000
Message-ID: <20050503101447.GA29973@gondor.apana.org.au>
References: <20050429144103.A23268@2ka.mipt.ru> <20050503095312.GA29788@gondor.apana.org.au> <1115115502.3414.22.camel@uganda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <1115115502.3414.22.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 03, 2005 at 02:18:22PM +0400, Evgeniy Polyakov wrote:
> 
> It can be compile option - those people who wants asynchronous crypto
> processing and has appropriate hardware will benefit from that even
> if theirs general purpose CPU is VIA with PadLock ACE.

Well if there were no better options then we'll have to do that.

However, I believe that with the right crypto API we should be
able to have async crypto support without sacrificing synchronous
performance.

> It looks like several CPUs can not be used for synchronous crypto
> processing in current IPsec implementation. Using asynchronous

That's just an implementation quirk.  I will be addressing that
soon as part of the xfrm locking clean-up.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
