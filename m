From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_htb: do not report fake rate estimators
Date: Wed, 26 Oct 2016 17:14:40 -0400 (EDT)
Message-ID: <20161026.171440.638427532009685965.davem@davemloft.net>
References: <1477065763.7065.84.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jikos@kernel.org, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42008 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbcJZVPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 17:15:11 -0400
In-Reply-To: <1477065763.7065.84.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Oct 2016 09:02:43 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When I prepared commit d250a5f90e53 ("pkt_sched: gen_estimator: Dont
> report fake rate estimators"), htb still had an implicit rate estimator
> for all its classes.
> 
> Then later, I made this rate estimator optional in commit 64153ce0a7b6
> ("net_sched: htb: do not setup default rate estimators"), but I forgot
> to update htb use of gnet_stats_copy_rate_est()
> 
> After this patch, "tc -s qdisc ..." no longer report fake rate
> estimators for HTB classes.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
