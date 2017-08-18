From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] net: sched: fix p_filter_chain check in
 tcf_chain_flush
Date: Fri, 18 Aug 2017 10:19:41 -0700 (PDT)
Message-ID: <20170818.101941.1615431063902854741.davem@davemloft.net>
References: <20170818081043.2130-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56820 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdHRRTm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 13:19:42 -0400
In-Reply-To: <20170818081043.2130-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 18 Aug 2017 10:10:43 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> The dereference before check is wrong and leads to an oops when
> p_filter_chain is NULL. The check needs to be done on the pointer to
> prevent NULL dereference.
> 
> Fixes: f93e1cdcf42c ("net/sched: fix filter flushing")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
