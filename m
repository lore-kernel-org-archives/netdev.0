From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] pkt_sched: Remove useless qdisc_stab_lock
Date: Fri, 17 Feb 2017 15:10:36 -0500 (EST)
Message-ID: <20170217.151036.1084044129536261272.davem@davemloft.net>
References: <1487313259-103328-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48274 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932303AbdBQUKi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 15:10:38 -0500
In-Reply-To: <1487313259-103328-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Fri, 17 Feb 2017 14:34:19 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> The qdisc_stab_lock is used in qdisc_get_stab and qdisc_put_stab.
> These two functions are invoked in qdisc_create, qdisc_change, and
> qdisc_destroy which run fully under RTNL.
> 
> So it already makes sure only one could access the qdisc_stab_list at
> the same time. Then it is unnecessary to use qdisc_stab_lock now.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied, thank you.
