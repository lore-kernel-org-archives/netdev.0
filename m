From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: use RCU to walk list of network
 devices
Date: Fri, 13 Nov 2009 20:39:21 -0800 (PST)
Message-ID: <20091113.203921.79518467.davem@davemloft.net>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.683253741@vyatta.com>
	<4AFB8246.6060804@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46838
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756749AbZKNEjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 23:39:05 -0500
In-Reply-To: <4AFB8246.6060804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Nov 2009 04:34:30 +0100

> [PATCH net-next-2.6] ipv6: use RCU to walk list of network devices
> 
> No longer need read_lock(&dev_base_lock), use RCU instead.
> We also can avoid taking references on inet6_dev structs.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
