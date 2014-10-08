From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: copy exts->type in tcf_exts_change()
Date: Wed, 08 Oct 2014 15:41:59 -0400 (EDT)
Message-ID: <20141008.154159.1714030561356451207.davem@davemloft.net>
References: <1412641314-17335-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, john.fastabend@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57038 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbaJHTmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 15:42:02 -0400
In-Reply-To: <1412641314-17335-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  6 Oct 2014 17:21:54 -0700

> We need to copy exts->type when committing the change, otherwise
> it would be always 0. This is a quick fix for -net and -stable,
> for net-next tcf_exts will be removed.
> 
> Fixes: commit 33be627159913b094bb578e83 ("net_sched: act: use standard struct list_head")
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Ok, applied and queued up for -stable, I'll sort out the merge hassles
with net-next too.
