From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Mon, 20 Sep 2004 23:18:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920231805.3f18479c.davem@davemloft.net>
References: <20040918203319.24004d6e.davem@davemloft.net>
	<1095645106.1048.190.camel@jzny.localdomain>
	<20040919195351.0b3560e6.davem@davemloft.net>
	<1095686672.1049.301.camel@jzny.localdomain>
	<20040920121123.70baf895.davem@davemloft.net>
	<20040921034212.GA28462@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040921034212.GA28462@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2004 13:42:12 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Sep 20, 2004 at 07:11:23PM +0000, David S. Miller wrote:
> > 
> > I believe I was successful in preserving existing behavior, but
> > I wonder if it makes sense any longer.  CONFIG_IP_ROUTE_TOS
> > changes not one data structure.  It does exactly:
> 
> Yes CONFIG_IP_ROUTE_TOS has out-lived its usefulness.  It has
> always seemed half-hearted compared to CONFIG_IP_ROUTE_FWMARK.

Ok, then I'm gonna nuke it.
