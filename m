From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sched: optimize class dumps
Date: Thu, 11 May 2017 21:38:04 -0400 (EDT)
Message-ID: <20170511.213804.55365186660390823.davem@davemloft.net>
References: <1494478768.7796.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jkosina@suse.cz, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56768 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932385AbdELBiG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 21:38:06 -0400
In-Reply-To: <1494478768.7796.108.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 May 2017 21:59:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 59cc1f61f09c ("net: sched: convert qdisc linked list to
> hashtable") we missed the opportunity to considerably speed up
> tc_dump_tclass_root() if a qdisc handle is provided by user.
> 
> Instead of iterating all the qdiscs, use qdisc_match_from_root()
> to directly get the one we look for.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
