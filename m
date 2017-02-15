From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [patch net-next] sched: have stub for tcf_destroy_chain in case
 NET_CLS is not configured
Date: Wed, 15 Feb 2017 18:17:18 +0100
Message-ID: <20170215171718.GA11757@bistromath.localdomain>
References: <1487156270-31132-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37976 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751583AbdBORRW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 12:17:22 -0500
Content-Disposition: inline
In-Reply-To: <1487156270-31132-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-02-15, 11:57:50 +0100, Jiri Pirko wrote:
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

Thanks for the fix.

Tested-by: Sabrina Dubroca <sd@queasysnail.net>

-- 
Sabrina
