From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 16:16:41 -0700 (PDT)
Message-ID: <20050517.161641.74747565.davem@davemloft.net>
References: <E1DYAHF-0006qW-00@gondolin.me.apana.org.au>
	<20050517.151352.41634495.davem@davemloft.net>
	<20050517230833.GA26604@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050517230833.GA26604@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 18 May 2005 09:08:33 +1000

> On Tue, May 17, 2005 at 03:13:52PM -0700, David S. Miller wrote:
> > And you protect against purposefully built malicious fragments how?
> 
> Is it any worse than what we've got now?

Good point, in both cases what ends up happening is that
the queue is invalidated.  In the existing case it's usually
because the final UDP or whatever checksum doesn't pass.
With your idea it'd be due to the artificially deflated timeout.
