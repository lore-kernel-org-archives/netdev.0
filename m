From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Fri, 29 Jun 2012 06:53:12 +0200
Message-ID: <1340945592.29822.8.camel@edumazet-glaptop>
References: <1340903237.13187.151.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>, netdev <netdev@vger.kernel.org>,
	codel@lists.bufferbloat.net, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>, Matt Mathis <mattmathis@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1340903237.13187.151.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-28 at 19:07 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> At enqueue time, check sojourn time of packet at head of the queue,
> and return NET_XMIT_CN instead of NET_XMIT_SUCCESS if this sejourn
> time is above codel @target.
> 
> This permits local TCP stack to call tcp_enter_cwr() and reduce its cwnd
> without drops (for example if ECN is not enabled for the flow)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Dave Taht <dave.taht@bufferbloat.net>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Matt Mathis <mattmathis@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Nandita Dukkipati <nanditad@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---

Please dont apply this patch, I'll submit an updated version later.

Thanks
