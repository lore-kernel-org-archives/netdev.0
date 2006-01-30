From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETFILTER] NAT sequence adjustment: Save eight bytes per
 conntrack
Date: Mon, 30 Jan 2006 15:50:44 -0800 (PST)
Message-ID: <20060130.155044.78283137.davem@davemloft.net>
References: <20060130232209.GG4603@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20060130232209.GG4603@sunbeam.de.gnumonks.org>
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
Date: Tue, 31 Jan 2006 00:22:09 +0100

> [NETFILTER] NAT sequence adjustment: Save eight bytes per conntrack
> 
> This patch reduces the size of 'struct ip_conntrack' on systems with NAT
> by eight bytes.  The sequence number delta values can be int16_t, since
> we only support one sequence number modification per window anyway, and
> one such modification is not going to exceed 32kB ;)
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied to net-2.6.17, thanks Harald.
