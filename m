From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Thu, 23 Sep 2004 22:39:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923223909.6f4da27f.davem@davemloft.net>
References: <20040920025802.GA11567@gondor.apana.org.au>
	<1095683660.1047.254.camel@jzny.localdomain>
	<414F1E12.6010808@eurodev.net>
	<20040922000503.GA13218@gondor.apana.org.au>
	<4150E7E5.2000001@eurodev.net>
	<20040922045239.GA19573@gondor.apana.org.au>
	<1095854920.1047.64.camel@jzny.localdomain>
	<20040922105221.59a67d4b.davem@davemloft.net>
	<4152EE68.4030803@eurodev.net>
	<20040923121651.51a58cf2.davem@davemloft.net>
	<20040924032830.GC6384@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@eurodev.net, hadi@cyberus.ca, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040924032830.GC6384@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2004 13:28:30 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Can someone please tell me why we need to do this at all?
> 
> Most of the dump messages should be close to PAGE_SIZE anyway, no?

It's moreso for the "give me a single entry" requests
than for dumps.  NLMSG_GOODSIZE is used for all cases.
