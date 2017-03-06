From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: phy: Do not perform software reset for
 Generic PHY
Date: Sun, 05 Mar 2017 17:58:11 -0800 (PST)
Message-ID: <20170305.175811.174357146943827777.davem@davemloft.net>
References: <20170305203449.14035-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, nbd@nbd.name,
        john@phrozen.org, cphealy@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34162 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752414AbdCFB6M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 20:58:12 -0500
In-Reply-To: <20170305203449.14035-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun,  5 Mar 2017 12:34:49 -0800

> The Generic PHY driver is a catch-all PHY driver and it should preserve
> whatever prior initialization has been done by boot loader or firmware
> agents. For specific PHY device configuration it is expected that a
> specialized PHY driver would take over that role.
> 
> Resetting the generic PHY was a bad idea that has lead to several
> complaints and downstream workarounds e.g: in OpenWrt/LEDE so restore
> the behavior prior to 87aa9f9c61ad ("net: phy: consolidate PHY
> reset in phy_init_hw()").
> 
> Reported-by: Felix Fietkau <nbd@nbd.name>
> Fixes: 87aa9f9c61ad ("net: phy: consolidate PHY reset in phy_init_hw()")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
