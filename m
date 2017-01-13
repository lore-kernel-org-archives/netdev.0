From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: systemport: Decouple flow control from
 __bcm_sysport_tx_reclaim
Date: Fri, 13 Jan 2017 12:20:03 -0500 (EST)
Message-ID: <20170113.122002.1603442400582097767.davem@davemloft.net>
References: <20170112200909.26825-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdAMRUJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:20:09 -0500
In-Reply-To: <20170112200909.26825-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 12 Jan 2017 12:09:09 -0800

> The __bcm_sysport_tx_reclaim() function is used to reclaim transmit
> resources in different places within the driver. Most of them should
> not affect the state of the transit flow control.
> 
> Introduce bcm_sysport_tx_clean() which cleans the ring, but does not
> re-enable flow control towards the networking stack, and make
> bcm_sysport_tx_reclaim() do the actual transmit queue flow control.
> 
> Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable.
