From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: 26 Mar 2005 15:11:15 -0500
Message-ID: <1111867875.1089.915.camel@jzny.localdomain>
References: <1111864971.1092.904.camel@jzny.localdomain>
	 <20050326194707.GA9872@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050326194707.GA9872@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-03-26 at 14:47, Herbert Xu wrote:

> Since we're adding new multicast groups, what about adding one for
> the passive event monitor? That way we can return ESRCH in km_query
> if there are no registered ACQUIRE listeners but still send messages
> to the monitor.
> 

Not sure how to do it for both PF_KEY and netlink. It does sound like a
reasonable thing to do. Thoughts?

cheers,
jamal
