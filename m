From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] LRO: fix return code propogation
Date: Fri, 22 Aug 2008 03:20:54 -0700 (PDT)
Message-ID: <20080822.032054.254235784.davem@davemloft.net>
References: <20080822005122.4697.26953.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49487
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760195AbYHVKUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 06:20:55 -0400
In-Reply-To: <20080822005122.4697.26953.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 21 Aug 2008 17:51:24 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> LRO code needs to propogate the return values from the netif_rx and
> netif_receive_skb calls specifically to allow drivers that need that
> information to react correctly.  Some places in the code couldn't
> return the result of the upcall to the stack, so I added the dropped
> counter, which just completes the cache line of the stats struct (on
> 64-bit), so shouldn't be a big deal.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Too vague a commit description.

This patch makes a bunch of routines return status codes, but there
is no given example of a precise intended usage.  That part might
be incorrect (the return value isn't actually needed or the code
in question is doing something wrong), which is why providing such
example is important.

So I'm dropping this.  Please provide such info in any resubmission or
I'll just ignore it, thanks.
