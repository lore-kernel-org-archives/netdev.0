From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] audit: remove useless synchronize_net()
Date: Thu, 01 Dec 2016 11:29:26 -0500 (EST)
Message-ID: <20161201.112926.207690425377488290.davem@davemloft.net>
References: <1480439696-21818-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rgb@redhat.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbcLAQ32 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:29:28 -0500
In-Reply-To: <1480439696-21818-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 29 Nov 2016 09:14:56 -0800

> netlink kernel socket is protected by refcount, not RCU.
> Its rcv path is neither protected by RCU. So the synchronize_net()
> is just pointless.
> 
> Cc: Richard Guy Briggs <rgb@redhat.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
