From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] [NET] Add skb_header_cloned and use it in e1000/tg3
Date: Wed, 9 Feb 2005 17:07:07 +1100
Message-ID: <20050209060707.GA8180@gondor.apana.org.au>
References: <20050122170533.GB11499@yakov.inr.ac.ru> <20050123071027.GA20296@gondor.apana.org.au> <20050126110043.GA29950@yakov.inr.ac.ru> <20050126222522.GA21670@gondor.apana.org.au> <20050127110946.GA20494@gondor.apana.org.au> <20050127111201.GB20494@gondor.apana.org.au> <20050128202542.GA23670@yakov.inr.ac.ru> <20050129031740.GA6130@gondor.apana.org.au> <20050129032210.GA7424@gondor.apana.org.au> <20050208210910.0ef6b8b6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050208210910.0ef6b8b6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Feb 08, 2005 at 09:09:10PM -0800, David S. Miller wrote:
> 
> These two patches look great.  I want to review them some more but
> I do intend to try and get them into 2.6.11-final.

Actually I would've thought that this is the sort of patch that
should wait until 2.6.12-pre is open.  The bug that it fixes
isn't that serious.  All I've heard so far are tcpdump showing
bogus results.

The potential for breakage on the other side is much more
significant.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
