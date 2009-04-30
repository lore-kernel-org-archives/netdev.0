From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
 sk_buff state
Date: Thu, 30 Apr 2009 11:05:49 -0700 (PDT)
Message-ID: <20090430.110549.62531937.davem@davemloft.net>
References: <20090430163200.GC15170@cuplxvomd02.corp.sa.net>
	<20090430.094614.13889468.davem@davemloft.net>
	<20090430175913.GA12737@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dvomlehn@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44580
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754245AbZD3SFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 14:05:55 -0400
In-Reply-To: <20090430175913.GA12737@cuplxvomd02.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <dvomlehn@cisco.com>
Date: Thu, 30 Apr 2009 10:59:13 -0700

> Your description is general enough that I may misunderstand your idea,
> but it sounds like, if debugging was on, you'd be recording every call to
> alloc_skb and kfree_skb in your table. This would use a lot of memory.
> You can't simply have a circular list, because an sk_buff might be allocated
> for a very long time before being used and you would overwrite its entry.
> This would reduce the reliability of the information, which is the last thing
> you want in a debugging tool. So, I'm considering approaches without this
> drawback.

A developer trying to diagnose something is explicitly turning
this on then trying to reproduce.  Since it's only on when wanted
we can either 1) make it really large or 2) allow the sysctl itself
to specify the table size.
