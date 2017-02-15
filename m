From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] sched: have stub for tcf_destroy_chain in
 case NET_CLS is not configured
Date: Wed, 15 Feb 2017 12:23:06 -0500 (EST)
Message-ID: <20170215.122306.126875220822657132.davem@davemloft.net>
References: <1487156270-31132-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, mlxsw@mellanox.com,
        sd@queasysnail.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752320AbdBORXI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 12:23:08 -0500
In-Reply-To: <1487156270-31132-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 15 Feb 2017 11:57:50 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> This fixes broken build for !NET_CLS:
> 
> net/built-in.o: In function `fq_codel_destroy':
> /home/sab/linux/net-next/net/sched/sch_fq_codel.c:468: undefined reference to `tcf_destroy_chain'
> 
> Fixes: cf1facda2f61 ("sched: move tcf_proto_destroy and tcf_destroy_chain helpers into cls_api")
> Reported-by: Sabrina Dubroca <sd@queasysnail.net>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
