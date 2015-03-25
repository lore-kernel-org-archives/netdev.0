From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: transmit multicast as unicast in source mode
Date: Tue, 24 Mar 2015 21:22:17 -0400 (EDT)
Message-ID: <20150324.212217.1935317955015686620.davem@davemloft.net>
References: <1427027389-9691-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de
To: michael-dev@fami-braun.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbbCYBWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 21:22:19 -0400
In-Reply-To: <1427027389-9691-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Braun <michael-dev@fami-braun.de>
Date: Sun, 22 Mar 2015 13:29:49 +0100

> When having multiple remote mac addresses assigned to different macvlan
> source devices created on top of the same other netdev, multicast packets
> send on one interface will be also received by the remote machines
> asssigned to the other macvlan device.
> 
> This is because multicast packets are transmitted as layer-2 multicast.
> Thought, not all protocols need their multicast packets to be transmitted
> as layer-2 multicast, esp. ARP, IPv4 and IPv6. Most importantly, IPv6
> router advertisments will be processed even if received as layer-2 unicast.
> 
> So this patch adds support for replicating multicast packets and sending
> them out as unicast by changing the destination mac address.
> This fixes IPv6 autoconf addresses and routes on the remote stations
> assigned to different macvlan devices.
> 
> There are two new flags: UNICAST and UNICAST_ALL. The first only rewrites
> ARP, IPv4 and IPv6 (and their 802.1Q tagged variant), the latter rewrites
> all multicast packets.
> 
> Signed-off-by: Michael Braun <michael-dev@fami-braun.de>

Since noone knowledgable has reviewed this patch, I'm not going to
apply it, sorry.
