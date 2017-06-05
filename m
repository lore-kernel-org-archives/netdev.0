From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: sched: select cls when cls_act is enabled
Date: Mon, 05 Jun 2017 10:57:01 -0400 (EDT)
Message-ID: <20170605.105701.2165458604629995851.davem@davemloft.net>
References: <20170604164928.15569-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        fengguang.wu@intel.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37734 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdFEO5D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 10:57:03 -0400
In-Reply-To: <20170604164928.15569-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun,  4 Jun 2017 18:49:28 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> It really makes no sense to have cls_act enabled without cls. In that
> case, the cls_act code is dead. So select it.
> 
> This also fixes an issue recently reported by kbuild robot:
> [linux-next:master 1326/4151] net/sched/act_api.c:37:18: error: implicit declaration of function 'tcf_chain_get'
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: db50514f9a9c ("net: sched: add termination action to allow goto chain")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
