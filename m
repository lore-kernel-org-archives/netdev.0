From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] driver: macvlan: Remove the rcu member of
 macvlan_port
Date: Wed, 07 Dec 2016 13:22:33 -0500 (EST)
Message-ID: <20161207.132233.1044197109019467837.davem@davemloft.net>
References: <1481084598-17351-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37142 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753132AbcLGSWe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:22:34 -0500
In-Reply-To: <1481084598-17351-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Wed,  7 Dec 2016 12:23:18 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> When free macvlan_port in macvlan_port_destroy, it is safe to free
> directly because netdev_rx_handler_unregister could enforce one
> grace period.
> So it is unnecessary to use kfree_rcu for macvlan_port.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
