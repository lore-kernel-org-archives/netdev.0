From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove duplicate neigh_ifdown
Date: Fri, 17 Dec 2010 10:14:03 -0800 (PST)
Message-ID: <20101217.101403.71116121.davem@davemloft.net>
References: <20101216194254.0f7c7e7b@nehalam>
	<20101217.094916.193712831.davem@davemloft.net>
	<20101217100101.5e6e6708@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52502
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754661Ab0LQSNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 13:13:34 -0500
In-Reply-To: <20101217100101.5e6e6708@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 17 Dec 2010 10:01:01 -0800

> Ok. It followed my last patch that did the rt6_ifdown only
> if not loopback. Since you accepted that, I sent the next one.

I applied it to net-2.6, which is how we handle bug fixes.  The
fix naturally propagates to net-next-2.6 the next tiem I do a merge.

This is why I found it quite strange when you were talking about
net-next-2.6 wrt. that bug fix.  We never apply clear important fixes
to net-next-2.6 first, then backport it to net-2.6

If such a net-2.6 dependency exists on a net-next-2.6 patch, you just
need to let me know about it so I can do the merge before applying it.
That's all.
