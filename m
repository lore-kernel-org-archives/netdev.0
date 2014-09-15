From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 3/5] net_sched: fix suspicious RCU usage in
 tcindex_classify()
Date: Mon, 15 Sep 2014 17:50:07 -0400 (EDT)
Message-ID: <20140915.175007.122084534795412397.davem@davemloft.net>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
	<1410815210-6693-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbaIOVuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:50:08 -0400
In-Reply-To: <1410815210-6693-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 15 Sep 2014 14:06:48 -0700

> This patch fixes the following kernel warning:
> 
> [   44.805900] [ INFO: suspicious RCU usage. ]
> [   44.808946] 3.17.0-rc4+ #610 Not tainted
> [   44.811831] -------------------------------
> [   44.814873] net/sched/cls_tcindex.c:84 suspicious rcu_dereference_check() usage!
> 
> Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
