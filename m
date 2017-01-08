From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Fix race condition in tg3_get_stats64().
Date: Sat, 07 Jan 2017 21:35:19 -0500 (EST)
Message-ID: <20170107.213519.1508383680566185628.davem@davemloft.net>
References: <1483737533-25059-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangyufen@huawei.com
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51272 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752528AbdAHCfV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 21:35:21 -0500
In-Reply-To: <1483737533-25059-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Fri,  6 Jan 2017 16:18:53 -0500

> The driver's ndo_get_stats64() method is not always called under RTNL.
> So it can race with driver close or ethtool reconfigurations.  Fix the
> race condition by taking tp->lock spinlock in tg3_free_consistent()
> when freeing the tp->hw_stats memory block.  tg3_get_stats64() is
> already taking tp->lock.
> 
> Reported-by: Wang Yufen <wangyufen@huawei.com>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>

Applied, thanks Michael.
