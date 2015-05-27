From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: invoke ->attach() after setting
 dev->qdisc
Date: Wed, 27 May 2015 14:11:08 -0400 (EDT)
Message-ID: <20150527.141108.991929705003103923.davem@davemloft.net>
References: <1432681729-1295-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbbE0SLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:11:11 -0400
In-Reply-To: <1432681729-1295-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 26 May 2015 16:08:48 -0700

> For mq qdisc, we add per tx queue qdisc to root qdisc
> for display purpose, however, that happens too early,
> before the new dev->qdisc is finally set, this causes
> q->list points to an old root qdisc which is going to be
> freed right before assigning with a new one.
> 
> Fix this by moving ->attach() after setting dev->qdisc.
> 
> For the record, this fixes the following crash:
 ...
> For long term, we probably need to clean up the qdisc_graft() code
> in case it hides other bugs like this.
> 
> Fixes: 95dc19299f74 ("pkt_sched: give visibility to mq slave qdiscs")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, and queued up for -stable, thanks!
