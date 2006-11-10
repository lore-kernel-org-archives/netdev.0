From: David Miller <davem@davemloft.net>
Subject: Re: [patch] make sch_fifo.o available when CONFIG_NET_SCHED is not
 set
Date: Thu, 09 Nov 2006 16:17:13 -0800 (PST)
Message-ID: <20061109.161713.125545134.davem@davemloft.net>
References: <20061031165324.GA20271@devicescape.com>
	<20061031232400.GE12964@postel.suug.ch>
	<20061108140618.GA17925@devicescape.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53193
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424297AbWKJARY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 19:17:24 -0500
To: david.kimdon@devicescape.com
In-Reply-To: <20061108140618.GA17925@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>
Date: Wed, 8 Nov 2006 06:06:18 -0800

> Based on patch by Patrick McHardy.
> 
> Add a new option, NET_SCH_FIFO, which provides a simple fifo qdisc
> without requiring CONFIG_NET_SCHED.
> 
> The d80211 stack needs a generic fifo qdisc for WME.  At present it
> uses net/d80211/fifo_qdisc.c which is functionally equivalent to
> sch_fifo.c.  This patch will allow the d80211 stack to remove
> net/d80211/fifo_qdisc.c and use sch_fifo.c instead. 
> 
> Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Applied to net-2.6.20, thanks David.
