From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/2] updates for [nf|ct]netlink and event API
Date: Thu, 30 Jun 2005 14:49:42 -0700 (PDT)
Message-ID: <20050630.144942.74731532.davem@davemloft.net>
References: <20050630180238.GM16076@postel.suug.ch>
	<42C46374.5000407@trash.net>
	<20050630213459.GO16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, hadi@cyberus.ca,
	pablo@eurodev.net, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: tgraf@suug.ch
In-Reply-To: <20050630213459.GO16076@postel.suug.ch>
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

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 30 Jun 2005 23:34:59 +0200

> This is only true if one attribute is added. What I really meant
> is something like em_text_dump() in em_text.c.

Speaking of em_text.c, when one loads ematch rules into that
module it does a printk().  I assume that's a thinko and should
be removed?
