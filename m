From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec xfrm resolution
Date: Fri, 18 Mar 2005 17:24:01 +1100
Message-ID: <20050318062401.GA4417@gondor.apana.org.au>
References: <20050209085251.GA9030@gondor.apana.org.au> <420B9DF1.3020704@trash.net> <20050210202810.GA1609@gondor.apana.org.au> <42144C3F.2060501@trash.net> <20050217091137.GA9476@gondor.apana.org.au> <42152841.5000707@trash.net> <20050218100854.GA19427@gondor.apana.org.au> <4216D6B4.5070901@trash.net> <20050219092314.GA8153@gondor.apana.org.au> <20050317203231.1b649f60.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050317203231.1b649f60.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 17, 2005 at 08:32:31PM -0800, David S. Miller wrote:
> On Sat, 19 Feb 2005 20:23:14 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > 1) The application must be able to react to MTU changes anyway.
> 
> This would seem to be the case, but keep in mind that if
> we're going through all this trouble to improve this
> quality of implementation issue, we should really get this
> right.

Don't worry, further down in that thread we agreed that optional
SAs will simply not be added so the MTU estimate will be correct
unless it's changed by PMTU later on.
 
> Anyways, in truth I'm being very picky :-)  Is there any prototype
> or beginnings of these ideas anywhere?

Not yet.  However, once the MTU stuff is out of the way I would like
to work on this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
