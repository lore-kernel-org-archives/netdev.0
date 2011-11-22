From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove netdev_alloc_page and use
 __GFP_COLD
Date: Tue, 22 Nov 2011 16:52:03 -0500 (EST)
Message-ID: <20111122.165203.2145992499287654130.davem@davemloft.net>
References: <1321995461.19663.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com, dm@chelsio.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756865Ab1KVVwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 16:52:08 -0500
In-Reply-To: <1321995461.19663.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Nov 2011 21:57:41 +0100

> Given we dont use anymore the struct net_device *dev argument, and this
> interface brings litle benefit, remove netdev_{alloc|free}_page(), to
> debloat include/linux/skbuff.h a bit.
> 
> (Some drivers used a mix of these interfaces and alloc_pages())
> 
> When allocating a page given to device for DMA transfert (device to
> memory), it makes sense to use a cold one (__GFP_COLD)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Dimitris Michailidis <dm@chelsio.com>

Fair enough, applied.
