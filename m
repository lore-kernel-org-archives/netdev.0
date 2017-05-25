From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: only create filter chains for new
 filters/actions
Date: Thu, 25 May 2017 12:14:56 -0400 (EDT)
Message-ID: <20170525.121456.221336477222052018.davem@davemloft.net>
References: <1495557757-31371-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, jiri@mellanox.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58630 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758135AbdEYQO6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:14:58 -0400
In-Reply-To: <1495557757-31371-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 23 May 2017 09:42:37 -0700

> tcf_chain_get() always creates a new filter chain if not found
> in existing ones. This is totally unnecessary when we get or
> delete filters, new chain should be only created for new filters
> (or new actions).
> 
> Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Indeed, get and delete requests should not create new objects, ever.

I have pretty much no idea why Jiri is making such a big fuss about
this change, to be quite honest. :-)

Applied, thanks Cong.
