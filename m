From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: convert unicast addr list
Date: Fri, 29 May 2009 22:15:28 -0700 (PDT)
Message-ID: <20090529.221528.251215500.davem@davemloft.net>
References: <20090523092215.GA3386@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755563AbZE3FP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 01:15:28 -0400
In-Reply-To: <20090523092215.GA3386@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 23 May 2009 11:22:17 +0200

> [PATCH net-next] net: convert unicast addr list
> 
> This patch converts unicast address list to standard list_head using previously
> introduced struct netdev_hw_addr. It also relaxes the locking. Original spinlock
> (still used for multicast addresses) is not needed and is no longer used for a
> protection of this list. All reading and writing takes place under rtnl (with no
> changes).
> 
> I also removed a possibility to specify the length of the address while adding
> or deleting unicast address. It's always dev->addr_len.
> 
> The convertion touched especially e1000 and ixgbe codes when the change is not
> so trivial.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Even though this touches some drivers non-trivially I like the
change a lot and driver folks have had multiple days to look
this over and say "hold off" if there were any major objections
and they didn't.

So applied to net-next-2.6, thanks!
