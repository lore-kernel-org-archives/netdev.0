From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: fix order of queue length updates in
 qdisc_replace()
Date: Sun, 20 Aug 2017 20:01:55 -0700 (PDT)
Message-ID: <20170820.200155.1157969593060834432.davem@davemloft.net>
References: <150314622756.18396.5215271249872220640.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751166AbdHUDB4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 23:01:56 -0400
In-Reply-To: <150314622756.18396.5215271249872220640.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Sat, 19 Aug 2017 15:37:07 +0300

> This important to call qdisc_tree_reduce_backlog() after changing queue
> length. Parent qdisc should deactivate class in ->qlen_notify() called from
> qdisc_tree_reduce_backlog() but this happens only if qdisc->q.qlen in zero.
> 
> Missed class deactivations leads to crashes/warnings at picking packets
> from empty qdisc and corrupting state at reactivating this class in future.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 86a7996cc8a0 ("net_sched: introduce qdisc_replace() helper")

Applied and queued up for -stable, thanks.

Please do not add an explict "CC: stable" to networking patches, simply
ask me to queue it up as I handle all networking -stable submissions
myself by hand.

Thank you.
