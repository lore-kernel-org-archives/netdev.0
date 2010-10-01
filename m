From: David Miller <davem@davemloft.net>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Thu, 30 Sep 2010 18:04:50 -0700 (PDT)
Message-ID: <20100930.180450.212395413.davem@davemloft.net>
References: <1285843234.2615.278.camel@edumazet-laptop>
	<4CA46B72.2090100@trash.net>
	<1285849004.2615.394.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, rl@hellgate.ch, jesse@nicira.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750954Ab0JABE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 21:04:29 -0400
In-Reply-To: <1285849004.2615.394.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Sep 2010 14:16:44 +0200

> [PATCH] vlan: dont drop packets from unknown vlans in promiscuous mode
> 
> Roger Luethi noticed packets for unknown VLANs getting silently dropped
> even in promiscuous mode.
> 
> Check for promiscuous mode in __vlan_hwaccel_rx() and vlan_gro_common()
> before drops.
> 
> As suggested by Patrick, mark such packets to have skb->pkt_type set to
> PACKET_OTHERHOST to make sure they are dropped by IP stack.
> 
> Reported-by: Roger Luethi <rl@hellgate.ch>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Patrick McHardy <kaber@trash.net>

Applied and queued up for -stable, thanks everyone!
