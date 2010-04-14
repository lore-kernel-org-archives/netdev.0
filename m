From: David Miller <davem@davemloft.net>
Subject: Re: [BUG net-next-2.6] fib: Some rcu warning
Date: Wed, 14 Apr 2010 16:12:40 -0700 (PDT)
Message-ID: <20100414.161240.04485387.davem@davemloft.net>
References: <1271274844.16881.1743.camel@edumazet-laptop>
	<1271275859.16881.1753.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54528
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756094Ab0DNXMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 19:12:37 -0400
In-Reply-To: <1271275859.16881.1753.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Apr 2010 22:10:59 +0200

> [PATCH] fib: suppress lockdep-RCU false positive in FIB trie.
> 
> Followup of commit 634a4b20
> 
> Allow tnode_get_child_rcu() to be called either under rcu_read_lock()
> protection or with RTNL held.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Since both your and Paul both posted an identical patch I'll
just add both of your signoffs to this one :-)

Since 634a4b20 is in net-2.6, this should probably go into
net-2.6 as well.

Thanks guys.
