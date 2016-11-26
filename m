From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] phy: fix error case of
 phy_led_triggers_(un)register
Date: Fri, 25 Nov 2016 19:59:27 -0500 (EST)
Message-ID: <20161125.195927.635503212934790387.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D40969DE2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zach.brown@ni.com, netdev@vger.kernel.org, f.fainelli@gmail.com,
        andrew@lunn.ch
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57656 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbcKZA7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:59:31 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40969DE2@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Wed, 23 Nov 2016 23:10:33 +0000

> From: Woojung Huh <woojung.huh@microchip.com>
> 
> When phy_init_hw() fails at phy_attach_direct();
> - phy_detach() calls phy_led_triggers_unregister() without
>   previous call of phy_led_triggers_register().
> - still call phy_led_triggers_register() and cause memory leak.
> 
> Fixes: 2e0bc452f472 ("net: phy: leds: add support for led triggers on phy link state change")
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Applied to net-next.
