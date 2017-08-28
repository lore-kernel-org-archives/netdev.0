From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] sched: sfq: drop packets after root qdisc
 lock is released
Date: Mon, 28 Aug 2017 15:52:02 -0700 (PDT)
Message-ID: <20170828.155202.392537637735368038.davem@davemloft.net>
References: <1503759538-32890-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        edumazet@google.com, netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50388 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751231AbdH1WwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:52:03 -0400
In-Reply-To: <1503759538-32890-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Sat, 26 Aug 2017 22:58:58 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The commit 520ac30f4551 ("net_sched: drop packets after root qdisc lock
> is released) made a big change of tc for performance. But there are
> some points which are not changed in SFQ enqueue operation.
> 1. Fail to find the SFQ hash slot;
> 2. When the queue is full;
> 
> Now use qdisc_drop instead free skb directly.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Applied, thank you.
