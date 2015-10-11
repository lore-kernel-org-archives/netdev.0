From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] sch_hhf: fix return value of hhf_drop()
Date: Sun, 11 Oct 2015 04:50:08 -0700 (PDT)
Message-ID: <20151011.045008.2132675615709931080.davem@davemloft.net>
References: <1444261652-3177-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, vtlam@google.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbbJKLeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 07:34:14 -0400
In-Reply-To: <1444261652-3177-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed,  7 Oct 2015 16:47:32 -0700

> Similar to commit c0afd9ce4d6a ("fq_codel: fix return value of fq_codel_drop()")
> ->drop() is supposed to return the number of bytes it dropped,
> but hhf_drop () returns the id of the bucket where it drops
> a packet from.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Terry Lam <vtlam@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied, thanks.
