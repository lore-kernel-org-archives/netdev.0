From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] lan78xx: Use irq_domain for phy interrupt
 from USB Int. EP
Date: Wed, 02 Nov 2016 15:24:41 -0400 (EDT)
Message-ID: <20161102.152441.459205528111412700.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D4095D3D8@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755953AbcKBTYn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 15:24:43 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D4095D3D8@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Tue, 1 Nov 2016 20:02:00 +0000

> From: Woojung Huh <woojung.huh@microchip.com>
> 
> To utilize phylib with interrupt fully than handling some of phy stuff in the MAC driver,
> create irq_domain for USB interrupt EP of phy interrupt and
> pass the irq number to phy_connect_direct() instead of PHY_IGNORE_INTERRUPT.
> 
> Idea comes from drivers/gpio/gpio-dl2.c
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Applied.
