From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: no need to free qdisc in RCU
 callback
Date: Tue, 19 Sep 2017 16:30:18 -0700 (PDT)
Message-ID: <20170919.163018.687882531516614878.davem@davemloft.net>
References: <20170919201542.14890-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, edumazet@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751074AbdISXaT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:30:19 -0400
In-Reply-To: <20170919201542.14890-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 19 Sep 2017 13:15:42 -0700

> gen estimator has been rewritten in commit 1c0d32fde5bd
> ("net_sched: gen_estimator: complete rewrite of rate estimators"),
> the caller no longer needs to wait for a grace period. So this
> patch gets rid of it.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Nice.

Applied, thanks.
