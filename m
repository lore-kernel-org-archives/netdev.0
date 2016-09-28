From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] net/sched: pkt_cls: change tc actions
 order to be as the user sets
Date: Wed, 28 Sep 2016 05:03:57 -0400 (EDT)
Message-ID: <20160928.050357.346200062373933950.davem@davemloft.net>
References: <1474963791-3717-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        ogerlitz@mellanox.com
To: hadarh@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59342 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752167AbcI1JED (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 05:04:03 -0400
In-Reply-To: <1474963791-3717-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>
Date: Tue, 27 Sep 2016 11:09:51 +0300

> Currently the created tc actions list is reversed against the order
> set by the user.
> Change the actions list order to be the same as was set by the user.
> 
> This patch doesn't affect dump actions behavior.
> For dumping, action->order parameter is used so the list order doesn't
> matter.
> 
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thanks.
