From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: Be drop monitor friendly
Date: Thu, 24 Aug 2017 18:24:50 -0700 (PDT)
Message-ID: <20170824.182450.412654136087195768.davem@davemloft.net>
References: <20170824225629.27850-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com, edumazet@gmail.com,
        pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59858 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754201AbdHYBYv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:24:51 -0400
In-Reply-To: <20170824225629.27850-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 24 Aug 2017 15:56:29 -0700

> There are 3 spots where we call dev_kfree_skb() but we are actually
> just doing a normal SKB consumption: __bcmgenet_tx_reclaim() for normal
> TX reclamation, bcmgenet_alloc_rx_buffers() during the initial RX ring
> setup and bcmgenet_free_rx_buffers() during RX ring cleanup.
> 
> Fixes: d6707bec5986 ("net: bcmgenet: rewrite bcmgenet_rx_refill()")
> Fixes: f48bed16a756 ("net: bcmgenet: Free skb after last Tx frag")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.

> David, I tagged these two commits, but this can actually go back
> to when the driver was first merged. Let me know if you would want
> me to provide -stable backports against other trees.

Ok, I'll queue these up for -stable.
