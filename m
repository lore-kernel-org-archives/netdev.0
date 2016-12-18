From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] r6040: move spinlock in r6040_close as
 SOFTIRQ-unsafe lock order detected
Date: Sat, 17 Dec 2016 21:36:30 -0500 (EST)
Message-ID: <20161217.213630.371461596447265670.davem@davemloft.net>
References: <1481826099-12840-1-git-send-email-manuel.bessler@sensus.com>
        <1481860500-25117-1-git-send-email-manuel.bessler@sensus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: manuel.bessler@sensus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47588 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752867AbcLRCgc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 21:36:32 -0500
In-Reply-To: <1481860500-25117-1-git-send-email-manuel.bessler@sensus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Bessler <manuel.bessler@sensus.com>
Date: Thu, 15 Dec 2016 22:55:00 -0500

> 'ifconfig eth0 down' makes r6040_close() trigger:
>  INFO: HARDIRQ-safe -> HARDIRQ-unsafe lock order detected
> 
> Fixed by moving calls to phy_stop(), napi_disable(), netif_stop_queue()
> to outside of the module's private spin_lock_irq block.
> 
> Found on a Versalogic Tomcat SBC with a Vortex86 SoC
 ...
> Signed-off-by: Manuel Bessler <manuel.bessler@sensus.com>

Applied, thanks.
