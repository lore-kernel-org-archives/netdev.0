From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: allocate rx queues in
 register_netdevice only
Date: Sun, 26 Sep 2010 19:05:09 -0700 (PDT)
Message-ID: <20100926.190509.258105871.davem@davemloft.net>
References: <1285273194.7794.24.camel@achroite.uk.solarflarecom.com>
	<1285296505.2380.43.camel@edumazet-laptop>
	<1285298795.2380.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57232
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757773Ab0I0CEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 22:04:49 -0400
In-Reply-To: <1285298795.2380.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 Sep 2010 05:26:35 +0200

> [PATCH net-next-2.6] rps: allocate rx queues in register_netdevice()
> 
> Instead of having two places were we allocate dev->_rx, introduce
> netif_alloc_rx_queues() helper and call it only from
> register_netdevice(), not from alloc_netdev_mq()
> 
> Goal is to let drivers change dev->num_rx_queues after allocating netdev
> and before registering it.
> 
> This also removes a lot of ifdefs in net/core/dev.c
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

Please cook up a patch that adds a check to make sure that
alloc_netdev_mq() is never called with number of queues < 1

Thanks again!

