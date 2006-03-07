From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NETFILTER] ip_queue: Fix wrong skb->len == nlmsg_len
 assumption
Date: Tue, 07 Mar 2006 13:58:53 +0100
Message-ID: <440D838D.8000302@trash.net>
References: <20060307123143.GO9559@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060307123143.GO9559@postel.suug.ch>
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

Thomas Graf wrote:
> The size of the skb carrying the netlink message is not
> equivalent to the length of the actual netlink message
> due to padding. ip_queue matches the length of the payload
> against the original packet size to determine if packet
> mangling is desired, due to the above wrong assumption
> arbitary packets may not be mangled depening on their
> original size.

Looks good, thanks Thomas. I think this should also go in 2.4.
