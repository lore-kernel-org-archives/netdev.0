From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netlink: defer socket destruction a bit
Date: Thu, 12 May 2005 20:36:39 +1000
Message-ID: <20050512103639.GA25631@gondor.apana.org.au>
References: <428284D6.9000804@tpack.net> <20050511222421.GA21331@gondor.apana.org.au> <4282889A.7080409@tpack.net> <20050511230309.GA21547@gondor.apana.org.au> <1115891821.30106.86.camel@tsc-6.cph.tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <1115891821.30106.86.camel@tsc-6.cph.tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 11:57:01AM +0200, Tommy Christensen wrote:
> 
> I moved the call to skb_orphan in the other patch, as you
> suggested.  I think that also makes this patch safe as it is.
> 
> Right?

Indeed it is.  This also means that we don't hold onto the skb's
share of rmalloc quota for an excessive amount of time if the
number of broadcast sockets is large.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
