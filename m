From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] fixed the size of the netlink message notified
 by inet6_rt_notify().
Date: Tue, 23 Jan 2007 22:14:43 -0800 (PST)
Message-ID: <20070123.221443.21926331.davem@davemloft.net>
References: <20070116.140159.02303722.takamiya@po.ntts.co.jp>
	<20070117105006.GV8693@postel.suug.ch>
	<45AE1792.1010002@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, takamiya@po.ntts.co.jp, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030246AbXAXGOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:14:44 -0500
In-Reply-To: <45AE1792.1010002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 17 Jan 2007 13:33:22 +0100

> Thomas Graf wrote:
> > * Noriaki TAKAMIYA <takamiya@po.ntts.co.jp> 2007-01-16 14:01
> >>
> >>  I think the return value of rt6_nlmsg_size() should includes the
> >>  amount of RTA_METRICS.
> >>
> >>Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
> > 
> > 
> > Acked-by: Thomas Graf <tgraf@suug.ch>
> 
> 
> Somewhat related: I have this patch for 2.6.21 to get rid of the
> BUG_ON()s.

I think this patch is a great idea, I'll stick this into my
net-2.6.21 tree when I open that up (perhaps this weekend).

