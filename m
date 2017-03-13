From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] net: sched: make default fifo qdiscs appear in
 the dump
Date: Sun, 12 Mar 2017 22:53:26 -0700 (PDT)
Message-ID: <20170312.225326.432231730454919673.davem@davemloft.net>
References: <alpine.LSU.2.20.1703081302240.31814@cbobk.fhfr.pm>
        <alpine.LSU.2.20.1703081602240.31814@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
        jhs@mojatatu.com, phil@nwl.cc, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jiri@resnulli.us
To: jikos@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbdCMFxa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 01:53:30 -0400
In-Reply-To: <alpine.LSU.2.20.1703081602240.31814@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Kosina <jikos@kernel.org>
Date: Wed, 8 Mar 2017 16:03:32 +0100 (CET)

> From: Jiri Kosina <jkosina@suse.cz>
> 
> The original reason [1] for having hidden qdiscs (potential scalability
> issues in qdisc_match_from_root() with single linked list in case of large
> amount of qdiscs) has been invalidated by 59cc1f61f0 ("net: sched: convert
> qdisc linked list to hashtable").
> 
> This allows us for bringing more clarity and determinism into the dump by
> making default pfifo qdiscs visible.
> 
> We're not turning this on by default though, at it was deemed [2] too
> intrusive / unnecessary change of default behavior towards userspace.
> Instead, TCA_DUMP_INVISIBLE netlink attribute is introduced, which allows
> applications to request complete qdisc hierarchy dump, including the
> ones that have always been implicit/invisible.
> 
> Singleton noop_qdisc stays invisible, as teaching the whole infrastructure
> about singletons would require quite some surgery with very little gain
> (seeing no qdisc or seeing noop qdisc in the dump is probably setting
> the same user expectation).
> 
> [1] http://lkml.kernel.org/r/1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com
> [2] http://lkml.kernel.org/r/20161021.105935.1907696543877061916.davem@davemloft.net
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Applied, thanks Jiri.
