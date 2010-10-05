From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add a core netdev->rx_dropped counter
Date: Tue, 05 Oct 2010 14:48:13 -0700 (PDT)
Message-ID: <20101005.144813.135535619.davem@davemloft.net>
References: <AANLkTi=Vdcn7xzJMPxkugvEVy32N7Bp=KVtir6NESnDF@mail.gmail.com>
	<1285909831.2705.41.camel@edumazet-laptop>
	<1285916815.2705.152.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, rl@hellgate.ch, netdev@vger.kernel.org,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58334
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751486Ab0JEVrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 17:47:53 -0400
In-Reply-To: <1285916815.2705.152.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 01 Oct 2010 09:06:55 +0200

> [PATCH net-next] net: add a core netdev->rx_dropped counter
> 
> In various situations, a device provides a packet to our stack and we
> drop it before it enters protocol stack :
> - softnet backlog full (accounted in /proc/net/softnet_stat)
> - bad vlan tag (not accounted)
> - unknown/unregistered protocol (not accounted)
> 
> We can handle a per-device counter of such dropped frames at core level,
> and automatically adds it to the device provided stats (rx_dropped), so
> that standard tools can be used (ifconfig, ip link, cat /proc/net/dev)
> 
> This is a generalization of commit 8990f468a (net: rx_dropped
> accounting), thus reverting it.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good to me, applied, thanks.
