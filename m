From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH net] tap: convert a mutex to a spinlock
Date: Tue, 11 Jul 2017 13:43:32 -0700 (PDT)
Message-ID: <20170711.134332.1783894537853836310.davem@davemloft.net>
References: <1499706350-12373-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borntraeger@de.ibm.com,
        eric.dumazet@gmail.com, sainath.grandhi@intel.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41758 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932525AbdGKUnd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 16:43:33 -0400
In-Reply-To: <1499706350-12373-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 10 Jul 2017 10:05:50 -0700

> We are not allowed to block on the RCU reader side, so can't
> just hold the mutex as before. As a quick fix, convert it to
> a spinlock.
> 
> Fixes: d9f1f61c0801 ("tap: Extending tap device create/destroy APIs")
> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Sainath Grandhi <sainath.grandhi@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
