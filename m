From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Thu, 23 Sep 2004 22:07:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923120707.GB32624@gondor.apana.org.au>
References: <1095633569.1047.107.camel@jzny.localdomain> <20040919231734.GA10124@gondor.apana.org.au> <1095647944.1046.206.camel@jzny.localdomain> <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net> <20040922045239.GA19573@gondor.apana.org.au> <1095854920.1047.64.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1095854920.1047.64.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2004 at 08:08:40AM -0400, jamal wrote:
>
> Since netlink is being used for a lot of things now, it may be time to
> obsolete those assumptions. 

I'm not against changes.  But so far I haven't seen anything concrete
about what these new things are yet :)

> Note also, theres a lot of wastage of that scarce sock buffer via page
> sized skbs - its not as trivial to fix, but would go some way to improve
> overrunning of the socket.

I wasn't aware of this scarcity problem.  Can you elaborate?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
