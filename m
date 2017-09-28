From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inetpeer: speed up inetpeer_invalidate_tree()
Date: Thu, 28 Sep 2017 09:41:18 -0700 (PDT)
Message-ID: <20170928.094118.1703457698817122114.davem@davemloft.net>
References: <1506356054.6617.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48520 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbdI1QlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 12:41:18 -0400
In-Reply-To: <1506356054.6617.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Sep 2017 09:14:14 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> As measured in my prior patch ("sch_netem: faster rb tree removal"),
> rbtree_postorder_for_each_entry_safe() is nice looking but much slower
> than using rb_next() directly, except when tree is small enough
> to fit in CPU caches (then the cost is the same)
> 
> From: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
