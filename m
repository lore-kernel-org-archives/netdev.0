From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: Sun, 27 Mar 2005 18:18:48 +1000
Message-ID: <20050327081848.GA13428@gondor.apana.org.au>
References: <1111864971.1092.904.camel@jzny.localdomain> <20050326194707.GA9872@gondor.apana.org.au> <1111867875.1089.915.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111867875.1089.915.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 26, 2005 at 03:11:15PM -0500, jamal wrote:
> On Sat, 2005-03-26 at 14:47, Herbert Xu wrote:
> 
> > Since we're adding new multicast groups, what about adding one for
> > the passive event monitor? That way we can return ESRCH in km_query
> > if there are no registered ACQUIRE listeners but still send messages
> > to the monitor.
> 
> Not sure how to do it for both PF_KEY and netlink. It does sound like a
> reasonable thing to do. Thoughts?

For non-standard extensions like this I wouldn't worry about PF_KEY.
After all, if you're going to make sense of all the messages from
the kernel you'll have to use netlink anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
