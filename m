From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 27 Sep 2004 08:53:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096289591.1075.45.camel@jzny.localdomain>
References: <20040920025802.GA11567@gondor.apana.org.au>
	 <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
	 <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net>
	 <20040922045239.GA19573@gondor.apana.org.au>
	 <1095854920.1047.64.camel@jzny.localdomain>
	 <20040922105221.59a67d4b.davem@davemloft.net>
	 <4152EE68.4030803@eurodev.net>
	 <20040923121651.51a58cf2.davem@davemloft.net>
	 <20040924032830.GC6384@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Pablo Neira <pablo@eurodev.net>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040924032830.GC6384@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-09-23 at 23:28, Herbert Xu wrote:

> Most of the dump messages should be close to PAGE_SIZE anyway, no?

20 bytes for the header; typical messages and attributes are in the
range of 20 bytes. In the problematic case #2 or #3 (from what i have
seen) in your previous email, you get events being broadcast to multiple
users occupying say 400 bytes or about 10 messages (~10%) when 4096 is
charged to the socket receive queue.

cheers,
jamal
