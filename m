From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: fix struct tc_u_hnode layout in u32
Date: Mon, 09 Mar 2015 23:45:20 -0400 (EDT)
Message-ID: <20150309.234520.322134640639140174.davem@davemloft.net>
References: <1425945820-9582-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, john.fastabend@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbbCJDpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 23:45:22 -0400
In-Reply-To: <1425945820-9582-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  9 Mar 2015 17:03:40 -0700

> We dynamically allocate divisor+1 entries for ->ht[] in tc_u_hnode:
> 
>   ht = kzalloc(sizeof(*ht) + divisor*sizeof(void *), GFP_KERNEL);
> 
> So ->ht is supposed to be the last field of this struct, however
> this is broken, since an rcu head is appended after it.
> 
> Fixes: 1ce87720d456 ("net: sched: make cls_u32 lockless")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
