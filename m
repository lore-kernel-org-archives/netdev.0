From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] drivers/net : avoid some skb->ip_summed
 initializations
Date: Thu, 02 Sep 2010 09:41:35 -0700 (PDT)
Message-ID: <20100902.094135.112603353.davem@davemloft.net>
References: <1283444746.2454.1132.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51045
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753264Ab0IBQlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 12:41:18 -0400
In-Reply-To: <1283444746.2454.1132.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Sep 2010 18:25:46 +0200

> fresh skbs have ip_summed set to CHECKSUM_NONE (0)
> 
> We can avoid setting again skb->ip_summed to CHECKSUM_NONE in drivers.
> 
> Introduce skb_CHECKSUM_NONE_assert() helper so that we keep this
> assertion documented in driver sources.
> 
> Change most occurrences of :
> 
> skb->ip_summed = CHECKSUM_NONE;
> 
> by :
> 
> skb_CHECKSUM_NONE_assert(skb);
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Please, no capital letters in C function names.

I'll apply this with that fixed up.

Thanks.
