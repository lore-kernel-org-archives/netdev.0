From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] updates for [nf|ct]netlink and event API
Date: Fri, 1 Jul 2005 00:08:14 +0200
Message-ID: <20050630220814.GP16076@postel.suug.ch>
References: <20050630180238.GM16076@postel.suug.ch>
	<42C46374.5000407@trash.net>
	<20050630213459.GO16076@postel.suug.ch>
	<20050630.144942.74731532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, hadi@cyberus.ca,
	pablo@eurodev.net, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050630.144942.74731532.davem@davemloft.net>
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

* David S. Miller <20050630.144942.74731532.davem@davemloft.net> 2005-06-30 14:49
> From: Thomas Graf <tgraf@suug.ch>
> Date: Thu, 30 Jun 2005 23:34:59 +0200
> 
> > This is only true if one attribute is added. What I really meant
> > is something like em_text_dump() in em_text.c.
> 
> Speaking of em_text.c, when one loads ematch rules into that
> module it does a printk().  I assume that's a thinko and should
> be removed?

Yes, it's a debugging leftover but I'll keep it in until rc3 so if
problems appear I have some debugging information. Given that is acceptable.
