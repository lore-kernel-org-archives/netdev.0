From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Tue, 29 Mar 2005 09:43:35 +1000
Message-ID: <20050328234335.GC15369@gondor.apana.org.au>
References: <1111864971.1092.904.camel@jzny.localdomain> <20050326194707.GA9872@gondor.apana.org.au> <1111867875.1089.915.camel@jzny.localdomain> <20050327081848.GA13428@gondor.apana.org.au> <1111950449.1089.938.camel@jzny.localdomain> <424875C7.3080306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <424875C7.3080306@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 28, 2005 at 11:23:19PM +0200, Patrick McHardy wrote:
> 
> To answer this question: no. xfrm_state_lock can be nested in
> x->lock, but not the other way around. If you want to avoid that

That's true for now but it's something that I'd like to change for
2.6.13.  We should use the refcnt as much as possible and modify
the locking so that the state lock is only used to guard the state
of the state :)

> the state changes below you, you could notify before insertion.

Agreed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
