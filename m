From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4] Make loopback idev stick around
Date: Tue, 15 Feb 2005 14:41:21 -0800
Message-ID: <20050215144121.702767c5.davem@davemloft.net>
References: <20050205053030.GA17412@gondor.apana.org.au>
	<20050205053532.GA17474@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050205053532.GA17474@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Feb 2005 16:35:32 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, Feb 05, 2005 at 04:30:30PM +1100, herbert wrote:
> > 
> > As it is when loopback_dev loses all of its IPv4 addresses its
> > corresponding idev will be destroyed.  Unfortunately as of last
> > August route.c relies on the loopback idev to kill references
> > to other idev objects.
> 
> The same problem exists for IPv6.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Both patches applied to the 2.6.12-pending tree.

I wish ->notifier_call()'s value was actually checked, we could
do intelligent things instead of panic()'ing when (for example)
loopback's idev allocation fails.
