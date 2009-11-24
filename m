From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: Fix device name compares
Date: Tue, 24 Nov 2009 14:51:04 -0800 (PST)
Message-ID: <20091124.145104.76461749.davem@davemloft.net>
References: <4B0AA8C9.8060206@gmail.com>
	<20091124.122135.43806243.davem@davemloft.net>
	<4B0C4CF3.3050307@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert@herjulf.net, netdev@vger.kernel.org, robert.olsson@its.uu.se
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52196
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934154AbZKXWuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 17:50:46 -0500
In-Reply-To: <4B0C4CF3.3050307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Nov 2009 22:15:31 +0100

> [PATCH] pktgen: Fix netdevice unregister
> 
> When multi queue compatable names are used by pktgen (eg eth0@0),
> we currently cannot unload a NIC driver if one of its device
> is currently in use.
> 
> Allow pktgen_find_dev() to find pktgen devices by their suffix (netdev name)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
