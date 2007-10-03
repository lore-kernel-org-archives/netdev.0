From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 03 Oct 2007 19:47:37 +0200
Message-ID: <4703D5B9.8050808@hartkopp.net>
References: <20071002142016.GE7881@ghostprotocols.net>	<4702B1FD.70102@hartkopp.net>	<20071002145236.3818bd63@freepuppy.rosehill> <20071002.150438.78357233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, urs@isnogud.escape.de,
	netdev@vger.kernel.org, kaber@trash.net, tglx@linutronix.de,
	yoshfuji@linux-ipv6.org, ebiederm@xmission.com,
	oliver.hartkopp@volkswagen.de, urs.thuermann@volkswagen.de
To: David Miller <davem@davemloft.net>, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:38847 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755482AbXJCRsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 13:48:06 -0400
In-Reply-To: <20071002.150438.78357233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Tue, 2 Oct 2007 14:52:36 -0700
>
>   
>> Please consider using netif_msg_xxx() and module parameter to set
>> default message level, like other real network drivers already do.
>>     
>
> I keep seeing this recommendation, but the two supposedly most mature
> and actively used drivers in the tree, tg3 and e1000 and e1000e, all
> do not use this scheme.
>
> In fact there are tons of drivers that even hook up the ethtool
> msg_level setting function and never even use the value.
>
> If people aren't using netif_msg_xxx() and the ethtool msg_level
> facilities properly, it's because there is a severe dearth of good
> example drivers to learn about it from.
>   

The currently available CAN netdevice drivers do not have a common debug 
concept neither any runtime control mechanism for this debugging. So 
netif_msg_xxx() is definitely worth to look at instead of creating any 
new stuff in this direction, before posting any 'real' CAN network 
driver here.

Thanks very much for that hint!

Oliver
