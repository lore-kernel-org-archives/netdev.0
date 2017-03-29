From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: Allow building mdio-boardinfo into
 the kernel
Date: Wed, 29 Mar 2017 10:32:58 -0700 (PDT)
Message-ID: <20170329.103258.1891990815121569336.davem@davemloft.net>
References: <20170328195709.13549-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, andrew@lunn.ch,
        rmk+kernel@armlinux.org.uk
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752454AbdC2RdD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 13:33:03 -0400
In-Reply-To: <20170328195709.13549-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 28 Mar 2017 12:57:09 -0700

> mdio-boardinfo contains code that is helpful for platforms to register
> specific MDIO bus devices independent of how CONFIG_MDIO_DEVICE or
> CONFIG_PHYLIB will be selected (modular or built-in). In order to make
> that possible, let's do the following:
> 
> - descend into drivers/net/phy/ unconditionally
> 
> - make mdiobus_setup_mdiodev_from_board_info() take a callback argument
>   which allows us not to expose the internal MDIO board info list and
>   mutex, yet maintain the logic within the same file
> 
> - relocate the code that creates a MDIO device into
>   drivers/net/phy/mdio_bus.c
> 
> - build mdio-boardinfo.o into the kernel as soon as MDIO_DEVICE is
>   defined (y or m)
> 
> Fixes: 90eff9096c01 ("net: phy: Allow splitting MDIO bus/device support from PHYs")
> Fixes: 648ea0134069 ("net: phy: Allow pre-declaration of MDIO devices")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
