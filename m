From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: bcmgenet: Utilize correct struct device
 for all DMA operations
Date: Fri, 02 Dec 2016 13:54:01 -0500 (EST)
Message-ID: <20161202.135401.1662791877536448974.davem@davemloft.net>
References: <1480614345-5827-1-git-send-email-florian.fainelli@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com,
        opendmb@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750842AbcLBSyC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:54:02 -0500
In-Reply-To: <1480614345-5827-1-git-send-email-florian.fainelli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  1 Dec 2016 09:45:45 -0800

> From: Florian Fainelli <f.fainelli@gmail.com>
> 
> __bcmgenet_tx_reclaim() and bcmgenet_free_rx_buffers() are not using the
> same struct device during unmap that was used for the map operation,
> which makes DMA-API debugging warn about it. Fix this by always using
> &priv->pdev->dev throughout the driver, using an identical device
> reference for all map/unmap calls.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
