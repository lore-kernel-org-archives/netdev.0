From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec xfrm resolution
Date: Sun, 20 Feb 2005 05:32:02 +1100
Message-ID: <20050219183202.GA10773@gondor.apana.org.au>
References: <20050209085251.GA9030@gondor.apana.org.au> <420B9DF1.3020704@trash.net> <20050210202810.GA1609@gondor.apana.org.au> <42144C3F.2060501@trash.net> <20050217091137.GA9476@gondor.apana.org.au> <42152841.5000707@trash.net> <20050218100854.GA19427@gondor.apana.org.au> <4216D6B4.5070901@trash.net> <20050219092314.GA8153@gondor.apana.org.au> <42173125.3040505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maillist netdev <netdev@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42173125.3040505@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 19, 2005 at 01:29:25PM +0100, Patrick McHardy wrote:
>
> This is not what happens currently. If an optional IPCOMP SA is missing
> it is skipped entirely. It is also legal to configure an optional
> ah/esp tunnel, although we don't accept such packets if the SA isn't
> present.

That's a bug.  How can you forward packets properly if the tunnel mode
SA is missing?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
