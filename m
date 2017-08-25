From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: systemport: Free DMA coherent descriptors on
 errors
Date: Thu, 24 Aug 2017 18:25:04 -0700 (PDT)
Message-ID: <20170824.182504.841848047841444681.davem@davemloft.net>
References: <20170824230113.15283-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754302AbdHYBZF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:25:05 -0400
In-Reply-To: <20170824230113.15283-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 24 Aug 2017 16:01:13 -0700

> In case bcm_sysport_init_tx_ring() is not able to allocate ring->cbs, we
> would return with an error, and call bcm_sysport_fini_tx_ring() and it
> would see that ring->cbs is NULL and do nothing. This would leak the
> coherent DMA descriptor area, so we need to free it on error before
> returning.
> 
> Reported-by: Eric Dumazet <edumazet@gmail.com>
> Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable.
