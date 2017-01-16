From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: do not enter direct reclaim from
 netlink_trim()
Date: Mon, 16 Jan 2017 13:39:55 -0500 (EST)
Message-ID: <20170116.133955.89348360657996924.davem@davemloft.net>
References: <1484327482.13165.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46014 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbdAPSj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 13:39:56 -0500
In-Reply-To: <1484327482.13165.38.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Jan 2017 09:11:22 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit d35c99ff77ecb ("netlink: do not enter direct reclaim from
> netlink_dump()") we made sure to not trigger expensive memory reclaim.
> 
> Problem is that a bit later, netlink_trim() might be called and
> trigger memory reclaim.
> 
> netlink_trim() should be best effort, and really as fast as possible.
> Under memory pressure, it is fine to not trim this skb.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
