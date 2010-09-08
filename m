From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Suppress lockdep-RCU false positive in FIB trie
 (3)
Date: Wed, 08 Sep 2010 14:14:47 -0700 (PDT)
Message-ID: <20100908.141447.200359390.davem@davemloft.net>
References: <20100907175117.GA1993@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50501
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754787Ab0IHVOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:14:30 -0400
In-Reply-To: <20100907175117.GA1993@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 7 Sep 2010 19:51:17 +0200

> Here is one more of these warnings and a patch below:
 ...
> Allow trie_firstleaf() to be called either under rcu_read_lock()
> protection or with RTNL held. The same annotation is added to
> node_parent_rcu() to prevent a similar warning a bit later.
> 
> Followup of commits 634a4b20 and 4eaa0e3c.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.
