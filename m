From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] udp: intoduce udp_encap_needed
	static_key
Date: Fri, 13 Apr 2012 13:41:08 -0400 (EDT)
Message-ID: <20120413.134108.1844473866612154303.davem@davemloft.net>
References: <20120412074159.GA10866@verge.net.au>
	<1334218829.5300.5903.camel@edumazet-glaptop>
	<1334221528.5300.6008.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcrl-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1334221528.5300.6008.camel@edumazet-glaptop>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 12 Apr 2012 11:05:28 +0200

> Most machines dont use UDP encapsulation (L2TP)
> 
> Adds a static_key so that udp_queue_rcv_skb() doesnt have to perform a
> test if L2TP never setup the encap_rcv on a socket.
> 
> Idea of this patch came after Simon Horman proposal to add a hook on TCP
> as well.
> 
> If static_key is not yet enabled, the fast path does a single JMP .
> 
> When static_key is enabled, JMP destination is patched to reach the real
> encap_type/encap_rcv logic, possibly adding cache misses.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied to net-next, thanks Eric.

Ban, please incorporate this scheme when you respin your
fixed ipv6 encap/l2tp patches.

Thanks.
