From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Thu, 31 Mar 2005 13:01:45 +1000
Message-ID: <20050331030145.GA27364@gondor.apana.org.au>
References: <1111864971.1092.904.camel@jzny.localdomain> <20050326194707.GA9872@gondor.apana.org.au> <1111867875.1089.915.camel@jzny.localdomain> <20050327081848.GA13428@gondor.apana.org.au> <1111950449.1089.938.camel@jzny.localdomain> <20050330004903.GA3399@gondor.apana.org.au> <1112237759.1092.35.camel@jzny.localdomain> <20050331030036.GA27309@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20050331030036.GA27309@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 31, 2005 at 01:00:36PM +1000, herbert wrote:
> On Wed, Mar 30, 2005 at 09:55:59PM -0500, jamal wrote:
> > 
> > Any objection to still calling it (new name) struct xfrm_sa_cb but
> > with only one 32 bit value in it - namely data?
> > This way i could add any other thing in the future in it without
> > changing the function call paramaters.
> 
> That's fine by me.

Actually, could you rename it to km_state_cb? This information is
only used for communication with the the km and it should be marked
as such just like the other km_* identifiers.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
