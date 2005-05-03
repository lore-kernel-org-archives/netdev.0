From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch/RFC]: Asynchronous IPsec processing.
Date: Tue, 3 May 2005 20:29:29 +1000
Message-ID: <20050503102929.GA30097@gondor.apana.org.au>
References: <20050429144103.A23268@2ka.mipt.ru> <20050503095312.GA29788@gondor.apana.org.au> <1115115502.3414.22.camel@uganda> <20050503101447.GA29973@gondor.apana.org.au> <1115116295.3414.30.camel@uganda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <1115116295.3414.30.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 03, 2005 at 02:31:35PM +0400, Evgeniy Polyakov wrote:
>
> Asynchronous processing will not hurt synchronous pathes in any way.

It will if you force everybody to go through the asynchronous path
because you're jacking up the latency.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
