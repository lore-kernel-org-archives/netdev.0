From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Super TSO v3
Date: Mon, 23 May 2005 19:38:17 -0700 (PDT)
Message-ID: <20050523.193817.112290763.davem@davemloft.net>
References: <20050524003208.GA25778@gondor.apana.org.au>
	<20050523.192917.48530622.davem@davemloft.net>
	<20050524023256.GA29242@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050524023256.GA29242@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 May 2005 12:32:57 +1000

> True, the Nagle algorithm itself aims to do something different
> from this function.  However, the act of turning Nagle off is
> an indication that the application wants to minimise the latency
> by sending things out ASAP.  So we should either respect that
> here by not delaying the packets to increase the TSO size, or
> we'll need a new socket option to do that for TSO.

Sure, we can check tp->nonagle to turn this deferring off.

But, I bet there are folks who want traditional Nagle turned
off, yet TSO chunking enabled.
