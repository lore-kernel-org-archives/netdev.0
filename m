From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fix ipv6_ifa_notify race
Date: Sat, 20 Nov 2004 06:35:04 +1100
Message-ID: <20041119193504.GB7339@gondor.apana.org.au>
References: <4197AC20.6020707@pobox.com> <E1CTR5h-0006ac-00@gondolin.me.apana.org.au> <20041119094924.GA3726@gondor.apana.org.au> <20041119.113658.109538461.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, acme@conectiva.com.br,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20041119.113658.109538461.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 19, 2004 at 11:36:58AM -0500, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> This patch is wrong (dead is not protected appropriately).

I don't understand your point.  ifp->dead is an int and it's read
and written atomically.

> I have another idea to fix this.

Great.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
