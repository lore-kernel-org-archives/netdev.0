From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/1] driver: ipvlan: Free ipvl_port
 directly with kfree instead of kfree_rcu
Date: Wed, 07 Dec 2016 13:22:27 -0500 (EST)
Message-ID: <20161207.132227.1409237486028723978.davem@davemloft.net>
References: <1481071487-11227-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37132 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753147AbcLGSWb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:22:31 -0500
In-Reply-To: <1481071487-11227-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Wed,  7 Dec 2016 08:44:47 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> There are two functions which would free the ipvl_port now. The first
> is ipvlan_port_create. It frees the ipvl_port in the error handler,
> so it could kfree it directly. The second is ipvlan_port_destroy. It
> invokes netdev_rx_handler_unregister which enforces one grace period
> by synchronize_net firstly, so it also could kfree the ipvl_port
> directly and safely.
> 
> So it is unnecessary to use kfree_rcu to free ipvl_port.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
