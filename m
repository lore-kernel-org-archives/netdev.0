From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: tunnels should use rcu_dereference
Date: Wed, 01 Sep 2010 10:58:08 -0700 (PDT)
Message-ID: <20100901.105808.85405762.davem@davemloft.net>
References: <1283202445.2405.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58766
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753687Ab0IAR5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 13:57:51 -0400
In-Reply-To: <1283202445.2405.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Aug 2010 23:07:25 +0200

> tunnel4_handlers, tunnel64_handlers, tunnel6_handlers and
> tunnel46_handlers are protected by RCU, but we dont use appropriate rcu
> primitives to scan them. rcu_lock() is already held by caller.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
