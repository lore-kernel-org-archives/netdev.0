From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: "Badness" again
Date: Sat, 15 Jan 2005 11:39:38 +0100
Message-ID: <20050115103938.GA14991@xi.wantstofly.org>
References: <41E83B8D.8020003@pobox.com> <20050114215833.GA12981@gondor.apana.org.au> <41E844AC.6040200@pobox.com> <20050115002638.GA13849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050115002638.GA13849@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jan 15, 2005 at 11:26:38AM +1100, Herbert Xu wrote:

> Neither is true here and therefore we may have a situation where
> the cached dst is released twice.  In fact I tracked down the
> address closest to the "badness" messages and it belongs to
> one of your domain's name servers.  That means the requests were
> probably made by named, which is multi-threaded.

The machine where I was seeing this (a HT P4) was indeed running
named as well.  This is the slave server for some zones, and the
master server, which had a pretty much identical sw configuration
(both Fedora 2, both using 6to4), is a (non-HT) Celeron and I never
saw it happening there.


--L
