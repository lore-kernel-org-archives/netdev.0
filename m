From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: fix stats handling
Date: Thu, 21 Oct 2010 03:56:03 -0700 (PDT)
Message-ID: <20101021.035603.233701260.davem@davemloft.net>
References: <20101021085740.12059.20577.stgit@localhost.localdomain>
	<20101021090001.12059.37088.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	eric.dumazet@gmail.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34643
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757075Ab0JUKzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:55:40 -0400
In-Reply-To: <20101021090001.12059.37088.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 21 Oct 2010 02:00:04 -0700

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Current ixgbe stats have following problems :
> 
> - Not 64 bit safe (on 32bit arches)
> 
> - Not safe in ixgbe_clean_rx_irq() :
>    All cpus dirty a common location (netdev->stats.rx_bytes &
> netdev->stats.rx_packets) without proper synchronization.
>    This slow down a bit multiqueue operations, and possibly miss some
> updates.
> 
> Fixes :
> 
> Implement ndo_get_stats64() method to provide accurate 64bit rx|tx
> bytes/packets counters, using 64bit safe infrastructure.
> 
> ixgbe_get_ethtool_stats() also use this infrastructure to provide 64bit
> safe counters.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
