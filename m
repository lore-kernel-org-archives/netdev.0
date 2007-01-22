From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [IPV6] fixed the size of the netlink message notified by inet6_rt_notify().
Date: Mon, 22 Jan 2007 13:39:40 +0100
Message-ID: <20070122123940.GE8693@postel.suug.ch>
References: <20070116.125728.278729390.takamiya@po.ntts.co.jp> <20070116.140159.02303722.takamiya@po.ntts.co.jp> <20070117105006.GV8693@postel.suug.ch> <45AE1792.1010002@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:35500 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453AbXAVMjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 07:39:20 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45AE1792.1010002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2007-01-17 13:33
> [NETLINK]: Don't BUG on undersized allocations
> 
> Currently netlink users BUG when the allocated skb for an event
> notification is undersized. While this is certainly a kernel bug,
> its not critical and crashing the kernel is too drastic, especially
> when considering that these errors have appeared multiple times in
> the past and it BUGs even if no listeners are present.
> 
> This patch replaces BUG by WARN_ON and changes the notification
> functions to inform potential listeners of undersized allocations
> using a unique error code (EMSGSIZE).

I perfectly agree, thanks a lot Patrick.
