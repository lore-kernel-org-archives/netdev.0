From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: fq: use proper locking in
 fq_dump_stats()
Date: Sun, 18 Sep 2016 22:17:06 -0400 (EDT)
Message-ID: <20160918.221706.1619375593697818367.davem@davemloft.net>
References: <1473981601.22679.64.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51800 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936277AbcISCRJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 22:17:09 -0400
In-Reply-To: <1473981601.22679.64.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Sep 2016 16:20:01 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When fq is used on 32bit kernels, we need to lock the qdisc before
> copying 64bit fields.
> 
> Otherwise "tc -s qdisc ..." might report bogus values.
> 
> Fixes: afe4fd062416 ("pkt_sched: fq: Fair Queue packet scheduler")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
