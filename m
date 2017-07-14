From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] netpoll: shut up a kernel warning on refcount
Date: Fri, 14 Jul 2017 08:17:40 -0700 (PDT)
Message-ID: <20170714.081740.1892120761671347344.davem@davemloft.net>
References: <1499900201-8676-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davej@codemonkey.org.uk,
        elena.reshetova@intel.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36220 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754500AbdGNPRm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 11:17:42 -0400
In-Reply-To: <1499900201-8676-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 12 Jul 2017 15:56:41 -0700

> When we convert atomic_t to refcount_t, a new kernel warning
> on "increment on 0" is introduced in the netpoll code,
> zap_completion_queue(). In fact for this special case, we know
> the refcount is 0 and we just have to set it to 1 to satisfy
> the following dev_kfree_skb_any(), so we can just use
> refcount_set(..., 1) instead.
> 
> Fixes: 633547973ffc ("net: convert sk_buff.users from atomic_t to refcount_t")
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Cc: Reshetova, Elena <elena.reshetova@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks Cong.
