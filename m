From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/2] net/sched: properly assign RCU pointer in
 tcf_chain_tp_insert/remove
Date: Tue, 23 May 2017 11:00:31 -0400 (EDT)
Message-ID: <20170523.110031.1093066756614344593.davem@davemloft.net>
References: <20170520130132.1626-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, daniel@iogearbox.net,
        simon.horman@netronome.com, mlxsw@mellanox.com,
        colin.king@canonical.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762534AbdEWPAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:00:43 -0400
In-Reply-To: <20170520130132.1626-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 20 May 2017 15:01:31 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> *p_filter_chain is rcu-dereferenced on reader path. So here in writer,
> property assign the pointer.
> 
> Fixes: 2190d1d0944f ("net: sched: introduce helpers to work with filter chains")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
