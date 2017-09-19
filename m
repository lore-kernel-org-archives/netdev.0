From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: sch_htb: add per class overlimits
 counter
Date: Mon, 18 Sep 2017 19:23:01 -0700 (PDT)
Message-ID: <20170918.192301.482791955113156206.davem@davemloft.net>
References: <1505763382.29839.27.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nuclearcat@nuclearcat.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35414 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751340AbdISCXE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 22:23:04 -0400
In-Reply-To: <1505763382.29839.27.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 18 Sep 2017 12:36:22 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> HTB qdisc overlimits counter is properly increased, but we have no per
> class counter, meaning it is difficult to diagnose HTB problems.
> 
> This patch adds this counter, visible in "tc -s class show dev eth0",
> with current iproute2.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>

Applied, thanks Eric.
