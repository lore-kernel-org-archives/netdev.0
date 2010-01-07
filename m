From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: RFC3069, private VLAN proxy arp support
Date: Thu, 07 Jan 2010 00:59:19 -0800 (PST)
Message-ID: <20100107.005919.138283009.davem@davemloft.net>
References: <20100105155047.13309.79610.stgit@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hawk@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47143
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932380Ab0AGI7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 03:59:10 -0500
In-Reply-To: <20100105155047.13309.79610.stgit@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>
Date: Tue, 05 Jan 2010 16:50:47 +0100

> This is to be used together with switch technologies, like RFC3069,
> that where the individual ports are not allowed to communicate with
> each other, but they are allowed to talk to the upstream router.  As
> described in RFC 3069, it is possible to allow these hosts to
> communicate through the upstream router by proxy_arp'ing.
> 
> This patch basically allow proxy arp replies back to the same
> interface (from which the ARP request/solicitation was received).
> 
> Tunable per device via proc "proxy_arp_pvlan":
>   /proc/sys/net/ipv4/conf/*/proxy_arp_pvlan
> 
> This switch technology is known by different vendor names:
>  - In RFC 3069 it is called VLAN Aggregation.
>  - Cisco and Allied Telesyn call it Private VLAN.
>  - Hewlett-Packard call it Source-Port filtering or port-isolation.
>  - Ericsson call it MAC-Forced Forwarding (RFC Draft).
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

Applied.
