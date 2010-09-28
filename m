From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 00/17] netdev: Fix queue count
 initialisation
Date: Mon, 27 Sep 2010 22:12:40 -0700 (PDT)
Message-ID: <20100927.221240.28820650.davem@davemloft.net>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41853
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754943Ab0I1FMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 01:12:20 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 27 Sep 2010 19:23:11 +0100

> This adds the functions:
> - netif_set_real_num_rx_queues() - set actual number of RX queues used
> - netif_copy_real_num_queues() - copy queue counts from another device
> 
> and changes all drivers that currently set
> net_device::real_num_tx_queues to use netif_set_real_num_tx_queues()
> and/or these functions.
> 
> The changes are compile-tested only, except that:
> - sfc and 8021q have been briefly tested
> - gianfar and mv643xx_eth have not been compiled, since they are
>   platform-specific
> 
> I noticed that the bonding driver sets its numbers of queues without
> regard to its slave devices.  This makes some sense since a bond device
> initially has no slave devices.  However, it seems to mean that a bond
> device can pass up an skb with an out-of-range queue_index, triggering a
> warning in get_rps_cpu().

Series applied, thanks Ben.
