From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch] make sch_fifo.o available when CONFIG_NET_SCHED is not set
Date: Wed, 1 Nov 2006 00:24:01 +0100
Message-ID: <20061031232400.GE12964@postel.suug.ch>
References: <20061031165324.GA20271@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:40607 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1946148AbWJaXXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 18:23:41 -0500
To: David Kimdon <david.kimdon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20061031165324.GA20271@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Kimdon <david.kimdon@devicescape.com> 2006-10-31 08:53
> You may see this discussion for more info:
> http://marc.theaimsgroup.com/?t=116181395100002&r=1&w=2
> 
> ----
> Based on a patch by Patrick McHardy.
> 
> Add a new option, NET_SCH_FIFO, which provides a simple fifo qdisc
> without requiring CONFIG_NET_SCHED.
> 
> The d80211 stack needs a generic fifo qdisc for WME.  At present it
> uses net/d80211/fifo_qdisc.c which is functionally equivalent to
> sch_fifo.c.  This patch will allow the d80211 stack to remove
> net/d80211/fifo_qdisc.c and use sch_fifo.c instead. 

I think NET_SCH_FIFO doesn't need a help text, should be invisible
to the user. Just select it from NET_SCHED and d80211.

