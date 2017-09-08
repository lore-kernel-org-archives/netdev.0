From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] net: sched: fix memleak for chain zero
Date: Thu, 07 Sep 2017 19:18:00 -0700 (PDT)
Message-ID: <20170907.191800.218886770521884093.davem@davemloft.net>
References: <20170906111419.5115-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        kubakici@wp.pl, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753161AbdIHCSB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 22:18:01 -0400
In-Reply-To: <20170906111419.5115-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  6 Sep 2017 13:14:19 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> There's a memleak happening for chain 0. The thing is, chain 0 needs to
> be always present, not created on demand. Therefore tcf_block_get upon
> creation of block calls the tcf_chain_create function directly. The
> chain is created with refcnt == 1, which is not correct in this case and
> causes the memleak. So move the refcnt increment into tcf_chain_get
> function even for the case when chain needs to be created.
> 
> Reported-by: Jakub Kicinski <kubakici@wp.pl>
> Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

This doesn't apply cleanly any more, please respin.

Thanks Jiri.
