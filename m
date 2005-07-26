From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] rename skb_ip_make_writable() to skb_make_writable()
Date: Tue, 26 Jul 2005 15:35:58 -0700 (PDT)
Message-ID: <20050726.153558.45067304.davem@davemloft.net>
References: <20050726152053.GA4279@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050726152053.GA4279@rama.de.gnumonks.org>
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
Date: Tue, 26 Jul 2005 17:20:53 +0200

> Rename skb_ip_make_writable() to skb_make_writable() since there is
> nothing IPv4-specific in it.  In fact, it was already used by IPv6, too...
> Upcoming nfnetlink_queue code will use it for any kind of packet.
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied.
