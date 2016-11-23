From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] phy: fix error case of phy_led_triggers_(un)register
Date: Wed, 23 Nov 2016 15:02:20 -0800
Message-ID: <af015fe1-d27a-97e0-29c1-5d423af0e9a4@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40969D0E@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Woojung.Huh@microchip.com, zach.brown@ni.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34620 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934812AbcKWXKh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 18:10:37 -0500
Received: by mail-oi0-f48.google.com with SMTP id y198so32783714oia.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 15:10:37 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40969D0E@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/11/2016 à 13:39, Woojung.Huh@microchip.com a écrit :
> From: Woojung Huh <woojung.huh@microchip.com>
> 
> When phy_init_hw() fails at phy_attach_direct();
> - phy_detach() calls phy_led_triggers_unregister() without 
>   previous call of phy_led_triggers_register().
> - still call phy_led_triggers_register() and cause memory leak.
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Since you probably have to resubmit this, can you also add a Fixes tag:

Fixes: 2e0bc452f472 ("net: phy: leds: add support for led triggers on
phy link state change")

Thanks!
-- 
Florian
