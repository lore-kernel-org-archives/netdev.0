From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] sched: Use __qdisc_drop instead of
 kfree_skb in sch_prio and sch_qfq
Date: Wed, 06 Sep 2017 21:20:38 -0700 (PDT)
Message-ID: <20170906.212038.1803486177079315112.davem@davemloft.net>
References: <1504506072-46207-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        edumazet@google.com, netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44320 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751048AbdIIFHP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 01:07:15 -0400
In-Reply-To: <1504506072-46207-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Mon,  4 Sep 2017 14:21:12 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The commit 520ac30f4551 ("net_sched: drop packets after root qdisc lock
> is released) made a big change of tc for performance. There are two points
> left in sch_prio and sch_qfq which are not changed with that commit. Now
> enhance them now with __qdisc_drop.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Thanks for catching these missed cases, applied.
