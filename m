From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] macvlan: add multiqueue capability
Date: Thu, 03 Sep 2009 20:10:57 -0700 (PDT)
Message-ID: <20090903.201057.33906063.davem@davemloft.net>
References: <4A9F9661.7020301@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932896AbZIDDKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:10:42 -0400
In-Reply-To: <4A9F9661.7020301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Sep 2009 12:11:45 +0200

> macvlan devices are currently not multi-queue capable.
> 
> We can do that defining rtnl_link_ops method,
> get_tx_queues(), called from rtnl_create_link()
> 
> This new method gets num_tx_queues/real_num_tx_queues
> from lower device.
> 
> macvlan_get_tx_queues() is a copy of vlan_get_tx_queues().
> 
> Because macvlan_start_xmit() has to update netdev_queue
> stats only (and not dev->stats), I chose to change
> tx_errors/tx_aborted_errors accounting to tx_dropped,
> since netdev_queue structure doesnt define tx_errors /
> tx_aborted_errors.
> 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
