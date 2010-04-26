From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bridge br_multicast: Ensure to initialize
 BR_INPUT_SKB_CB(skb)->mrouters_only.
Date: Mon, 26 Apr 2010 11:26:03 -0700 (PDT)
Message-ID: <20100426.112603.28806882.davem@davemloft.net>
References: <201004251859.o3PIx7Vo012485@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45670
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644Ab0DZSZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 14:25:58 -0400
In-Reply-To: <201004251859.o3PIx7Vo012485@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Mon, 26 Apr 2010 03:59:07 +0900

> Even with commit 32dec5dd0233ebffa9cae25ce7ba6daeb7df4467 ("bridge
> br_multicast: Don't refer to BR_INPUT_SKB_CB(skb)->mrouters_only
> without IGMP snooping."), BR_INPUT_SKB_CB(skb)->mrouters_only is
> not appropriately initialized if IGMP snooping support is
> compiled and disabled, so we can see garbage.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
