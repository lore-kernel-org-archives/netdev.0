From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: fix a use-after-free in tc_ctl_tfilter()
Date: Sat, 09 May 2015 16:14:29 -0400 (EDT)
Message-ID: <20150509.161429.1861093639473391686.davem@davemloft.net>
References: <1430864522-15691-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbEIUOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:14:30 -0400
In-Reply-To: <1430864522-15691-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  5 May 2015 15:22:02 -0700

> When tcf_destroy() returns true, tp could be already destroyed,
> we should not use tp->next after that.
> 
> For long term, we probably should move tp list to list_head.
> 
> Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thank you.
