From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: Fwd: [2.6] ethertap and af_inet.c assertion failures
Date: Sat, 15 Jan 2005 17:19:59 +0100
Message-ID: <41E942AF.3030202@tpack.net>
References: <E1Cpo1q-0007lI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: simon.roscic@chello.at, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1Cpo1q-0007lI-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Since the skb will be orphaned on its way to the destination anyway,
> let's simply do that before the trimming.  This shouldn't lead to
> skb leakage since the skb will either be charged to the destination
> socket or freed.

Looks fine. This will solve the problem for other callers as well.

Shouldn't there be a check for skb_shared as well? Or are the
callers of netlink_unicast/broadcast supposed to avoid this.

-Tommy
