From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec xfrm resolution
Date: Sun, 20 Feb 2005 17:57:20 +1100
Message-ID: <20050220065720.GA26175@gondor.apana.org.au>
References: <42152841.5000707@trash.net> <20050218100854.GA19427@gondor.apana.org.au> <4216D6B4.5070901@trash.net> <20050219092314.GA8153@gondor.apana.org.au> <42173125.3040505@trash.net> <20050219183202.GA10773@gondor.apana.org.au> <421789AF.4020705@trash.net> <20050219190333.GA22166@gondor.apana.org.au> <4217993D.4070107@trash.net> <4217A0DA.7050409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maillist netdev <netdev@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4217A0DA.7050409@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 19, 2005 at 09:26:02PM +0100, Patrick McHardy wrote:
> 
> How about this patch ? It ignores "optional" for missing tunnel mode 
> SAs, symetric
> to input.

Actually, I've been convinced by your earlier argument :)

I now think that IPCOMP users like racoon/openswan should simply
not set the optional flag on the sending policy.  It only needs
to be set on the receiving side.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
