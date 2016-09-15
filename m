From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: act_tunnel_key: Remove
 rcu_read_lock protection
Date: Thu, 15 Sep 2016 19:18:32 -0400 (EDT)
Message-ID: <20160915.191832.731244761336539212.davem@davemloft.net>
References: <1473682762-8150-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, jbenc@redhat.com,
        jhs@mojatatu.com, shmulik.ladkani@gmail.com, tom@herbertland.com,
        edumazet@google.com, xiyou.wangcong@gmail.com, amirva@mellanox.com,
        ogerlitz@mellanox.com
To: hadarh@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbcIOXSh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 19:18:37 -0400
In-Reply-To: <1473682762-8150-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>
Date: Mon, 12 Sep 2016 15:19:21 +0300

> Remove rcu_read_lock protection from tunnel_key_dump and use
> rtnl_dereference, dump operation is protected by  rtnl lock.
> 
> Also, remove rcu_read_lock from tunnel_key_release and use
> rcu_dereference_protected.
> 
> Both operations are running exclusively and a writer couldn't modify
> t->params while those functions are executed.
> 
> Fixes: 54d94fd89d90 ('net/sched: Introduce act_tunnel_key')
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Applied.
