From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Sun, 27 Mar 2005 18:24:22 +1000
Message-ID: <20050327082422.GA25302@gondor.apana.org.au>
References: <1111864971.1092.904.camel@jzny.localdomain> <20050326194006.GA9737@gondor.apana.org.au> <1111867505.1089.907.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111867505.1089.907.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 26, 2005 at 03:05:05PM -0500, jamal wrote:
>
> > Is the intention that you'll be sending policy expire messages to
> > POLEXPIRE only?
> 
> Right. Unless you think this will break existing apps?

Yes openswan listens on XFRMGRP_EXPIRE for poilcy expire messages
to detect unused pass policies that were automatically generated.

> Maybe i should leave EXPIRE alone?

I think so.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
