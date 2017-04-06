From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: check noop_qdisc before qdisc_hash_add()
Date: Thu, 06 Apr 2017 12:29:45 -0700 (PDT)
Message-ID: <20170406.122945.2116775205917467295.davem@davemloft.net>
References: <1491357091-27064-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, edumazet@google.com,
        jkosina@suse.cz
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36840 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753125AbdDFT3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 15:29:52 -0400
In-Reply-To: <1491357091-27064-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  4 Apr 2017 18:51:30 -0700

> Dmitry reported a crash when injecting faults in
> attach_one_default_qdisc() and dev->qdisc is still
> a noop_disc, the check before qdisc_hash_add() fails
> to catch it because it tests NULL. We should test
> against noop_qdisc since it is the default qdisc
> at this point.
> 
> Fixes: 59cc1f61f09c ("net: sched: convert qdisc linked list to hashtable")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Jiri Kosina <jkosina@suse.cz>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable.
