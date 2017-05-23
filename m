From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] net/sched: fix filter flushing
Date: Tue, 23 May 2017 11:00:48 -0400 (EDT)
Message-ID: <20170523.110048.220295415915420000.davem@davemloft.net>
References: <20170520130132.1626-1-jiri@resnulli.us>
        <20170520130132.1626-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, daniel@iogearbox.net,
        simon.horman@netronome.com, mlxsw@mellanox.com,
        colin.king@canonical.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753078AbdEWPA5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:00:57 -0400
In-Reply-To: <20170520130132.1626-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 20 May 2017 15:01:32 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> When user instructs to remove all filters from chain, we cannot destroy
> the chain as other actions may hold a reference. Also the put in errout
> would try to destroy it again. So instead, just walk the chain and remove
> all existing filters.
> 
> Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
