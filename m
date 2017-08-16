From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched/sfq: update hierarchical backlog when drop
 packet
Date: Tue, 15 Aug 2017 17:17:05 -0700 (PDT)
Message-ID: <20170815.171705.613945360349558700.davem@davemloft.net>
References: <150280422406.717624.15125218636935056461.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jhs@mojatatu.com
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44052 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752888AbdHPARG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:17:06 -0400
In-Reply-To: <150280422406.717624.15125218636935056461.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 15 Aug 2017 16:37:04 +0300

> When sfq_enqueue() drops head packet or packet from another queue it
> have to update backlog at upper qdiscs too.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")

Applied and queued up for -stable.
