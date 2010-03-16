From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bridge br_multicast: Don't refer to
 BR_INPUT_SKB_CB(skb)->mrouters_only without IGMP snooping.
Date: Tue, 16 Mar 2010 14:34:34 -0700 (PDT)
Message-ID: <20100316.143434.134315497.davem@davemloft.net>
References: <201003160751.o2G7pIwM022633@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48442
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758191Ab0CPVeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:34:13 -0400
In-Reply-To: <201003160751.o2G7pIwM022633@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 16 Mar 2010 16:51:18 +0900

> Without CONFIG_BRIDGE_IGMP_SNOOPING,
> BR_INPUT_SKB_CB(skb)->mrouters_only is not appropriately
> initialized, so we can see garbage.
> 
> A clear option to fix this is to set it even without that
> config, but we cannot optimize out the branch.
> 
> Let's introduce a macro that returns value of mrouters_only
> and let it return 0 without CONFIG_BRIDGE_IGMP_SNOOPING.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thank you.
