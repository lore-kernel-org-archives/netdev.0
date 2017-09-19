From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] net: speedup netns create/delete time
Date: Tue, 19 Sep 2017 16:32:53 -0700 (PDT)
Message-ID: <20170919.163253.740450667943070639.davem@davemloft.net>
References: <20170919232709.14690-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
        eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51110 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdISXcy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:32:54 -0400
In-Reply-To: <20170919232709.14690-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 19 Sep 2017 16:27:02 -0700

> When rate of netns creation/deletion is high enough,
> we observe softlockups in cleanup_net() caused by huge list
> of netns and way too many rcu_barrier() calls.
> 
> This patch series does some optimizations in kobject,
> and add batching to tunnels so that netns dismantles are
> less costly.
 ...

Series applied, thanks Eric.
