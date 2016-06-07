From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: keep backlog updated with qlen
Date: Mon, 06 Jun 2016 21:15:16 -0400 (EDT)
Message-ID: <20160606.211516.119527470608167374.davem@davemloft.net>
References: <1464991557-5135-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stasn77@gmail.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbcFGBPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 21:15:19 -0400
In-Reply-To: <1464991557-5135-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri,  3 Jun 2016 15:05:57 -0700

> For gso_skb we only update qlen, backlog should be updated too.
> 
> Note, it is correct to just update these stats at one layer,
> because the gso_skb is cached there.
> 
> Reported-by: Stas Nichiporovich <stasn77@gmail.com>
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
