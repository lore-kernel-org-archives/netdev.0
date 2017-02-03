From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove support for per driver
 ndo_busy_poll()
Date: Fri, 03 Feb 2017 17:18:20 -0500 (EST)
Message-ID: <20170203.171820.956894207079399896.davem@davemloft.net>
References: <1486089808.21871.59.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56844 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdBCWSW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:18:22 -0500
In-Reply-To: <1486089808.21871.59.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 18:43:28 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> We added generic support for busy polling in NAPI layer in linux-4.5
> 
> No network driver uses ndo_busy_poll() anymore, we can get rid
> of the pointer in struct net_device_ops, and its use in sk_busy_loop()
> 
> Saves NETIF_F_BUSY_POLL features bit.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
