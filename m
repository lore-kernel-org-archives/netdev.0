From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: avoid calling tcf_unbind_filter()
 in call_rcu callback
Date: Wed, 01 Oct 2014 22:01:23 -0400 (EDT)
Message-ID: <20141001.220123.1054083748022563765.davem@davemloft.net>
References: <1412118444-29179-1-git-send-email-xiyou.wangcong@gmail.com>
	<1412118444-29179-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754143AbaJBCBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 22:01:24 -0400
In-Reply-To: <1412118444-29179-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 30 Sep 2014 16:07:24 -0700

> This fixes the following crash:
 ...
> tp could be freed in call_rcu callback too, the order is not guaranteed.
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, and I added John's description of why this is legal to the
commit message.
