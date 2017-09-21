From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: always reset qdisc backlog in qdisc_reset()
Date: Thu, 21 Sep 2017 11:57:54 -0700 (PDT)
Message-ID: <20170921.115754.1809328103208394223.davem@davemloft.net>
References: <150591153693.113604.8604505743746410801.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jhs@mojatatu.com
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdIUS5z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 14:57:55 -0400
In-Reply-To: <150591153693.113604.8604505743746410801.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Wed, 20 Sep 2017 15:45:36 +0300

> SKB stored in qdisc->gso_skb also counted into backlog.
> 
> Some qdiscs don't reset backlog to zero in ->reset(),
> for example sfq just dequeue and free all queued skb.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")

Applied and queued up for -stable.
