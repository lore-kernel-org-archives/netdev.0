From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fwd: [2.6] ethertap and af_inet.c assertion failures
Date: Mon, 17 Jan 2005 13:37:51 -0800
Message-ID: <20050117133751.6d2421fa.davem@davemloft.net>
References: <41E44476.20303@tpack.net>
	<E1Cpo1q-0007lI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tommy.christensen@tpack.net, simon.roscic@chello.at, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1Cpo1q-0007lI-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 16 Jan 2005 00:31:46 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Tommy Christensen <tommy.christensen@tpack.net> wrote:
> > 
> > netlink has messed up the send buffer accounting, when trimming a skb.
> 
> You are spot on.  Dave, you were right too about checking for charged
> skb's in netlink_trim.

It's good to know that I'm legitimately paranoid from time to
time :-)

> Since the skb will be orphaned on its way to the destination anyway,
> let's simply do that before the trimming.  This shouldn't lead to
> skb leakage since the skb will either be charged to the destination
> socket or freed.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, I'll apply this.

Thanks Herbert.
