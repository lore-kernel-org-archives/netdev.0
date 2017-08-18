From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net/sched: Fix the logic error to decide the
 ingress qdisc
Date: Fri, 18 Aug 2017 10:29:29 -0700 (PDT)
Message-ID: <20170818.102929.1752805484538604868.davem@davemloft.net>
References: <1503055460-36795-1-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: chrism@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57040 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751126AbdHRR3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 13:29:30 -0400
In-Reply-To: <1503055460-36795-1-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Mi <chrism@mellanox.com>
Date: Fri, 18 Aug 2017 07:24:20 -0400

> The offending commit used a newly added helper function.
> But the logic is wrong. Without this fix, the affected NICs
> can't do HW offload. Error -EOPNOTSUPP will be returned directly.
> 
> Fixes: a2e8da9378cc ("net/sched: use newly added classid identity helpers")
> Signed-off-by: Chris Mi <chrism@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied.
