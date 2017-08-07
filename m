From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] netvsc: fix rtnl deadlock on unregister
 of vf
Date: Sun, 06 Aug 2017 21:29:29 -0700 (PDT)
Message-ID: <20170806.212929.246667029504105138.davem@davemloft.net>
References: <20170804191400.22471-1-sthemmin@microsoft.com>
        <20170804191400.22471-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50452 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751433AbdHGE3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 00:29:30 -0400
In-Reply-To: <20170804191400.22471-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri,  4 Aug 2017 12:14:00 -0700

> With new transparent VF support, it is possible to get a deadlock
> when some of the deferred work is running and the unregister_vf
> is trying to cancel the work element. The solution is to use
> trylock and reschedule (similar to bonding and team device).
> 
> Reported-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> Fixes: 0c195567a8f6 ("netvsc: transparent VF management")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied, thanks.
