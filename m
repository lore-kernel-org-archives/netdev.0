From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: sched: cls_matchall: fix null pointer
 dereference
Date: Mon, 22 May 2017 14:54:46 -0400 (EDT)
Message-ID: <20170522.145446.597984501091102550.davem@davemloft.net>
References: <20170522144613.22848-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, colin.king@canonical.com, yotamg@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760390AbdEVSyv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:54:51 -0400
In-Reply-To: <20170522144613.22848-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 22 May 2017 16:46:13 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Since the head is guaranteed by the check above to be null, the call_rcu
> would explode. Remove the previously logically dead code that was made
> logically very much alive and kicking.
> 
> Fixes: 985538eee06f ("net/sched: remove redundant null check on head")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Ouch... that's kinda scary.

This fix is needed in the 'net' tree so that's where I have applied
it.

Thanks.
