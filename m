From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.10-rc] ipv6: Process unicast packet with Router Alert
 by checking flag in skb.
Date: Tue, 25 Jun 2013 14:47:43 -0700 (PDT)
Message-ID: <20130625.144743.33061613678996547.davem@davemloft.net>
References: <51C50839.7070804@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785Ab3FYVrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 17:47:46 -0400
In-Reply-To: <51C50839.7070804@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 22 Jun 2013 11:13:13 +0900

> Router Alert option is marked in skb.
> Previously, IP6CB(skb)->ra was set to positive value for such packets.
> Since commit dd3332bf ("ipv6: Store Router Alert option in IP6CB
> directly."), IP6SKB_ROUTERALERT is set in IP6CB(skb)->flags, and
> the value of Router Alert option (in network byte order) is set
> to IP6CB(skb)->ra for such packets.
> 
> Multicast forwarding path uses that flag and value, but unicast
> forwarding path does not use the flag and misuses IP6CB(skb)->ra
> value.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
