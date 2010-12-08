From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pktgen: adding prefetchw() call
Date: Wed, 08 Dec 2010 10:17:43 -0800 (PST)
Message-ID: <20101208.101743.112598404.davem@davemloft.net>
References: <20101206063349.GA6147@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, robert.olsson@its.uu.se,
	john.r.fastabend@intel.com, andy.shevchenko@gmail.com,
	netdev@vger.kernel.org
To: junchangwang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755502Ab0LHSRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:17:15 -0500
In-Reply-To: <20101206063349.GA6147@Desktop-Junchang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Junchang Wang <junchangwang@gmail.com>
Date: Mon, 6 Dec 2010 14:33:52 +0800

> 
> We know for sure pktgen is going to write skb->data right after
> *_alloc_skb, causing unnecessary cache misses.
> 
> Idea is to add a prefetchw() call to prefetch the first cache line
> indicated by skb->data. On systems with Adjacent Cache Line Prefetch,
> it's probably two cache lines are prefetched.
> 
> With this prefetch, pktgen on Intel SR1625 server with two E5530 
> quad-core processors and a single ixgbe-based NIC went from 8.63Mpps
> to 9.03Mpps, with 4.6% improvement.
> 
> 
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>

Your patch was corrupted by your email client, please fix this up
and resubmit.
