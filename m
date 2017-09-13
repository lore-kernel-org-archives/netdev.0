From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: gen_estimator: fix scaling error in
 bytes/packets samples
Date: Wed, 13 Sep 2017 13:34:09 -0700 (PDT)
Message-ID: <20170913.133409.1977805397875181373.davem@davemloft.net>
References: <9b8cdc2b39fdd2d0be7b5f559b2034e7@nuclearcat.com>
        <1505320949.15310.173.camel@edumazet-glaptop3.roam.corp.google.com>
        <1505326605.15310.193.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nuclearcat@nuclearcat.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56812 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751112AbdIMUeM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 16:34:12 -0400
In-Reply-To: <1505326605.15310.193.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Sep 2017 11:16:45 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Denys reported wrong rate estimations with HTB classes.
> 
> It appears the bug was added in linux-4.10, since my tests
> where using intervals of one second only.
> 
> HTB using 4 sec default rate estimators, reported rates
> were 4x higher.
> 
> We need to properly scale the bytes/packets samples before
> integrating them in EWMA.
> 
> Tested:
 ...
> Fixes: 1c0d32fde5bd ("net_sched: gen_estimator: complete rewrite of rate estimators")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>

Applied and queued up for -stable, thanks Eric.
