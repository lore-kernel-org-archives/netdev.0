From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: reorder struct netdev_hw_addr
Date: Sun, 19 Sep 2010 11:24:10 -0700 (PDT)
Message-ID: <20100919.112410.112586709.davem@davemloft.net>
References: <1284790664.4373.610.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60975
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754998Ab0ISSXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 14:23:51 -0400
In-Reply-To: <1284790664.4373.610.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 18 Sep 2010 08:17:44 +0200

> Move 'synced' and 'global_use' fields before 'refcount', to shrinks
> struct netdev_hw_addr by 8 bytes (on 64bit arches).
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
