From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: remove warning from qdisc_hash_add
Date: Tue, 15 Aug 2017 17:17:10 -0700 (PDT)
Message-ID: <20170815.171710.1104857144261787251.davem@davemloft.net>
References: <150280434474.717808.1684163881218427525.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jkosina@suse.cz,
        edumazet@google.com, jhs@mojatatu.com
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44064 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752937AbdHPARL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:17:11 -0400
In-Reply-To: <150280434474.717808.1684163881218427525.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 15 Aug 2017 16:39:05 +0300

> It was added in commit e57a784d8cae ("pkt_sched: set root qdisc
> before change() in attach_default_qdiscs()") to hide duplicates
> from "tc qdisc show" for incative deivices.
> 
> After 59cc1f61f ("net: sched: convert qdisc linked list to hashtable")
> it triggered when classful qdisc is added to inactive device because
> default qdiscs are added before switching root qdisc.
> 
> Anyway after commit ea3274695353 ("net: sched: avoid duplicates in
> qdisc dump") duplicates are filtered right in dumper.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied.
