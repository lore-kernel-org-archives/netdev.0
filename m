From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] tipc: fix a dangling pointer
Date: Thu, 26 Oct 2017 17:48:18 +0900 (KST)
Message-ID: <20171026.174818.99139632308003939.davem@davemloft.net>
References: <20171024224449.8197-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
        ying.xue@windriver.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59568 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdJZIsW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:48:22 -0400
In-Reply-To: <20171024224449.8197-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 24 Oct 2017 15:44:49 -0700

> tsk->group is set to grp earlier, but we forget to unset it
> after grp is freed.
> 
> Fixes: 75da2163dbb6 ("tipc: introduce communication groups")
> Reported-by: syzkaller bot
> Cc: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
