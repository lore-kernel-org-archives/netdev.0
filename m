From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPv4] Check PAGE_SIZE in fz_hash_alloc
Date: Thu, 23 Sep 2004 13:05:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923130521.7029a724.davem@davemloft.net>
References: <20040918203319.24004d6e.davem@davemloft.net>
	<1095645106.1048.190.camel@jzny.localdomain>
	<20040919195351.0b3560e6.davem@davemloft.net>
	<1095686672.1049.301.camel@jzny.localdomain>
	<20040920121123.70baf895.davem@davemloft.net>
	<20040921034212.GA28462@gondor.apana.org.au>
	<20040920231805.3f18479c.davem@davemloft.net>
	<20040922020729.GA14062@gondor.apana.org.au>
	<20040921193234.1c5b09a1.davem@davemloft.net>
	<20040922035710.GA17249@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040922035710.GA17249@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 13:57:10 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is a minor optimisation to fz_hash_alloc.  The break-even point
> should be based on PAGE_SIZE rather than the value of divisor.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

It happens to be equivalent on several platforms, but yes
good fixup :-)
