From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: sched: choke: remove dead filter
 classify code
Date: Fri, 24 Mar 2017 12:47:41 -0700 (PDT)
Message-ID: <20170324.124741.1497247366241339255.davem@davemloft.net>
References: <1490284936-19412-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965599AbdCXTrn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 15:47:43 -0400
In-Reply-To: <1490284936-19412-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 23 Mar 2017 17:02:16 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> sch_choke is classless qdisc so it does not define cl_ops. Therefore
> filter_list cannot be ever changed, being NULL all the time.
> Reason is this check in tc_ctl_tfilter:
> 
> 	/* Is it classful? */
> 	cops = q->ops->cl_ops;
> 	if (!cops)
> 		return -EINVAL;
> 
> So remove this dead code.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
