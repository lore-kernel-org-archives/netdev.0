From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] MASQUERADE: inherit masq_index to slave connections
Date: Sat, 30 Jul 2005 17:45:00 -0700 (PDT)
Message-ID: <20050730.174500.122593208.davem@davemloft.net>
References: <20050730135511.GE6620@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050730135511.GE6620@rama.de.gnumonks.org>
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

From: Harald Welte <laforge@netfilter.org>
Date: Sat, 30 Jul 2005 15:55:12 +0200

> [NETFILTER] Inherit masq_index to slave connections
> 
> masq_index is used for cleanup in case the interface address changes
> (such as a dialup ppp link with dynamic addreses).  Without this patch,
> slave connections are not evicted in such a case, since they don't inherit
> masq_index.
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied, thanks Harald.
