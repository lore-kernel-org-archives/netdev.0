From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: Mon, 4 Apr 2005 12:46:00 +1000
Message-ID: <20050404024600.GA17507@gondor.apana.org.au>
References: <1112403845.1088.14.camel@jzny.localdomain> <20050402012813.GA24575@gondor.apana.org.au> <1112406164.1088.54.camel@jzny.localdomain> <20050402014619.GB24861@gondor.apana.org.au> <1112469601.1088.173.camel@jzny.localdomain> <1112538718.1096.394.camel@jzny.localdomain> <20050404005805.GA16543@gondor.apana.org.au> <1112579761.1096.412.camel@jzny.localdomain> <20050404022601.GA17293@gondor.apana.org.au> <1112582396.1096.427.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112582396.1096.427.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 03, 2005 at 10:39:56PM -0400, jamal wrote:
> On Sun, 2005-04-03 at 22:26, Herbert Xu wrote:
>
> > I think that decision should be made by the KM.  So you wouldn't do it
> > for PFKEY, but netlink should definitely do it.
> 
> Is it possible to have non-root privileged pfkey sockets. If yes,
> then it makes sense.

Currently Linux requires CAP_NET_ADMIN for PFKEY.  However, this
may not be the case on other systems.  That's the reason why the
RFC requires that the keys not be sent via PFKEY.

However for netlink there is no such issue.

Even if we do eventually open up netlink for non-root listeners
(this will actually require structural changes to netlink itself),
we can create a new multicast group for non-privileged users that
don't get the keys.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
