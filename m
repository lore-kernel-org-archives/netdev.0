From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: factorize cache clearing for batched
 unregister operations
Date: Tue, 17 Nov 2009 00:34:49 -0800 (PST)
Message-ID: <20091117.003449.153994565.davem@davemloft.net>
References: <200911170149.50011.opurdila@ixiacom.com>
	<20091116160646.39c0a1ac@nehalam>
	<200911170922.08486.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49547
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754726AbZKQIec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 03:34:32 -0500
In-Reply-To: <200911170922.08486.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Tue, 17 Nov 2009 09:22:08 +0200

> BTW, it appears we don't have a route cache for IPv6. Right?

That's right, no IPV6 route cache.

But it doesn't seem to matter so much, as routing tables are
still small in that realm.  Although I heard the trend is for
that to change.

I also suspect that with things like policy routing we could run into
problems, but we have a multi-way tree for the IPV6 routing table
datastructure explicitly to handle those kinds of things.
