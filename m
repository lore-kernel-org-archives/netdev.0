From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Mon, 27 Sep 2004 12:12:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927121209.4d3d7e28.davem@davemloft.net>
References: <20040925005623.2faf8faf.davem@davemloft.net>
	<E1CBtvC-0000yM-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CBtvC-0000yM-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 21:43:58 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> David S. Miller <davem@davemloft.net> wrote:
> > 
> > 2) Tim Gardner's change to smooth out periodic neighbour GC.
> 
> I think tbl->gc_interval can be killed altogether now.

Let's keep it around so we don't break scripts people
have writing sysctl/procfs values to that thing.
