From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch/RFC]: Asynchronous IPsec processing.
Date: Tue, 3 May 2005 19:53:12 +1000
Message-ID: <20050503095312.GA29788@gondor.apana.org.au>
References: <20050429144103.A23268@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20050429144103.A23268@2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 29, 2005 at 02:41:03PM +0400, Evgeniy Polyakov wrote:
> 
> I've created POC code to perform asynchronous IPsec [ESP]
> processing. Please comment about bugs in the following patch.
> It of course very dirty - but it is only begining, 
> I just want to know if approach is right.
> Patch was tested with several ssh session and some 
> traffic like find / and tcpdump over them.

IMHO we should ensure that the async code path does not adversely
impact synchronous crypto performance.  Most users will be using
synchronous crypto primitives.  Synchronous crypto is also the best
way to utilise VIA Padlock which is arguably the best hardware crypto
solution that's available today.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
