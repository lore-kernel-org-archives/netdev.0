From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Tue, 15 Aug 2006 14:23:00 +0200
Message-ID: <20060815122300.GV14627@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch> <20060815003614.GA8677@ms2.inr.ac.ru> <20060815111735.GU14627@postel.suug.ch> <200608151508.36848.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jamal <hadi@cyberus.ca>,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38113 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932509AbWHOMWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 08:22:40 -0400
To: Hasso Tepper <hasso@estpak.ee>
Content-Disposition: inline
In-Reply-To: <200608151508.36848.hasso@estpak.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Hasso Tepper <hasso@estpak.ee> 2006-08-15 15:08
> Thomas Graf wrote:
> > However, I changed IPv4 addresses to provide the pid and support
> > NLM_F_ECHO and the same will follow for IPv6 address notifications
> > which will mean that quagga sees a different set of IPv4 address
> > notifications.
> 
> Can you explain what exactly is changed?

IPv4 address notifications originating from a netlink request now
carry the netlink pid of the request instead of 0.
