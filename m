From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [NETFILTER] ip_queue: Fix wrong skb->len == nlmsg_len
 assumption
Date: Tue, 07 Mar 2006 15:01:37 -0800 (PST)
Message-ID: <20060307.150137.63762785.davem@davemloft.net>
References: <20060307123143.GO9559@postel.suug.ch> <440D838D.8000302@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <440D838D.8000302@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 07 Mar 2006 13:58:53 +0100

> Thomas Graf wrote:
> > The size of the skb carrying the netlink message is not
> > equivalent to the length of the actual netlink message
> > due to padding. ip_queue matches the length of the payload
> > against the original packet size to determine if packet
> > mangling is desired, due to the above wrong assumption
> > arbitary packets may not be mangled depening on their
> > original size.
> 
> Looks good, thanks Thomas. I think this should also go in 2.4.

Pushed to 2.6.16, 2.6.x stable, and 2.4.x.

Phew!

Thanks Thomas.
