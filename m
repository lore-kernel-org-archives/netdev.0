From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net: revert "net_sched: move tp->root allocation
 into fw_init()"
Date: Thu, 24 Sep 2015 14:34:35 -0700 (PDT)
Message-ID: <20150924.143435.1365222226800107560.davem@davemloft.net>
References: <1442966471-22656-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akshat.1984@gmail.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbbIXVeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 17:34:36 -0400
In-Reply-To: <1442966471-22656-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 22 Sep 2015 17:01:11 -0700

> fw filter uses tp->root==NULL to check if it is the old method,
> so it doesn't need allocation at all in this case. This patch
> reverts the offending commit and adds some comments for old
> method to make it obvious.
> 
> Fixes: 33f8b9ecdb15 ("net_sched: move tp->root allocation into fw_init()")
> Reported-by: Akshat Kakkar <akshat.1984@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
