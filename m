From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v4 00/10] net: sched: introduce multichain
 support for filters
Date: Wed, 17 May 2017 15:22:35 -0400 (EDT)
Message-ID: <20170517.152235.915849138276472997.davem@davemloft.net>
References: <20170517090803.4461-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752011AbdEQTWi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 15:22:38 -0400
In-Reply-To: <20170517090803.4461-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 17 May 2017 11:07:53 +0200

> Currently, each classful qdisc holds one chain of filters.
> This chain is traversed and each filter could be matched on, which
> may lead to execution of list of actions. One of such action
> could be "reclassify", which would "reset" the processing of the
> filter chain.
> 
> So this filter chain could be looked at as a flat table.
> Sometimes it is convenient for user to configure a hierarchy
> of tables. Example usecase is encapsulation.
> 
> Hierarchy of tables is a common way how it is done in HW pipelines.
> So it is much more convenient to offload this.
> 
> This patchset contains two major patches:
> 8/10 - This patch introduces the support for having multiple
>        chains of filters.
> 10/10 - This patch adds new control action to allow going to specified chain
> 
> The rest of the patches are smaller or bigger depencies of those 2.
> Please see individual patch descriptions for details.

Series applied, thanks Jiri.
