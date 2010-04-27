From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: fix a lockdep rcu warning in
 __sk_dst_set()
Date: Tue, 27 Apr 2010 12:55:23 -0700 (PDT)
Message-ID: <20100427.125523.123992473.davem@davemloft.net>
References: <1272350443.4861.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49569
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756756Ab0D0TzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:55:18 -0400
In-Reply-To: <1272350443.4861.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Apr 2010 08:40:43 +0200

> __sk_dst_set() might be called while no state can be integrated in a
> rcu_dereference_check() condition.
> 
> So use rcu_dereference_raw() to shutup lockdep warnings (if
> CONFIG_PROVE_RCU is set)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
