From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec xfrm resolution
Date: Sun, 20 Feb 2005 06:03:33 +1100
Message-ID: <20050219190333.GA22166@gondor.apana.org.au>
References: <20050210202810.GA1609@gondor.apana.org.au> <42144C3F.2060501@trash.net> <20050217091137.GA9476@gondor.apana.org.au> <42152841.5000707@trash.net> <20050218100854.GA19427@gondor.apana.org.au> <4216D6B4.5070901@trash.net> <20050219092314.GA8153@gondor.apana.org.au> <42173125.3040505@trash.net> <20050219183202.GA10773@gondor.apana.org.au> <421789AF.4020705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maillist netdev <netdev@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <421789AF.4020705@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 19, 2005 at 07:47:11PM +0100, Patrick McHardy wrote:
>
> >That's a bug.  How can you forward packets properly if the tunnel mode
> >SA is missing?
>
> Using normal routing. What meaning would "optional" have otherwise ?
> If the encapsulation has to be done, the user shouldn't mark the SA
> as optional in my opinion.

In that case you can't mark IPCOMP SAs as optional in this scenario
which is the most common application of optional:

IPCOMP(tunnel) -- ESP(transport)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
