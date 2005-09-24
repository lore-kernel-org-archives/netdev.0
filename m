From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [NETFILTER] ip_conntrack: Update event cache when
 status changes
Date: Sat, 24 Sep 2005 16:56:28 -0700 (PDT)
Message-ID: <20050924.165628.86591859.davem@davemloft.net>
References: <20050924185020.GC731@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050924185020.GC731@sunbeam.de.gnumonks.org>
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
Date: Sat, 24 Sep 2005 20:50:20 +0200

> [NETFILTER] ip_conntrack: Update event cache when status changes
> 
> The GRE, SCTP and TCP protocol helpers did not call ip_conntrack_event_cache()
> when updating ct->status.  This patch adds the respective calls.
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied, thanks Harald.
