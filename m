From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Wed, 30 Mar 2005 23:27:17 +1000
Message-ID: <20050330132717.GA11163@gondor.apana.org.au>
References: <1111864971.1092.904.camel@jzny.localdomain> <20050326194707.GA9872@gondor.apana.org.au> <1111867875.1089.915.camel@jzny.localdomain> <20050327081848.GA13428@gondor.apana.org.au> <1111950449.1089.938.camel@jzny.localdomain> <20050330125518.GA10853@gondor.apana.org.au> <1112188704.1088.170.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112188704.1088.170.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2005 at 08:18:25AM -0500, jamal wrote:
> 
> we let the km make the call; pfkey already had these calls and i believe
> they are the ones that should go in order to be generic. Actually more
> like split into two. But thats defered for later (if it ever gets done).

Yes you're right.  I thought you were putting it into xfrm_state_insert
but that's not the case.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
