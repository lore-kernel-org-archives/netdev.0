From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] net: phy: Allow splitting MDIO
 bus/device support
Date: Fri, 24 Mar 2017 12:51:31 -0700 (PDT)
Message-ID: <20170324.125131.1293972732808794085.davem@davemloft.net>
References: <20170323170119.4004-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        arnd@arndb.de
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43642 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965968AbdCXTvd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 15:51:33 -0400
In-Reply-To: <20170323170119.4004-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 23 Mar 2017 10:01:16 -0700

> This patch series allows building support for MDIO bus controllers which
> are sometimes usable and necessary in cases where there are no Ethernet PHYs.
> 
> Changes in v3:
> - corrected of_mdio compile guards for prototypes vs. stubs
> - added a missing OF_MDIO dependency for MDIO_BCM_UNIMAC
> - fixed Kbuild bot reported errors against mdio-bitbang
> 
> Changes in v2:
> - implement Russell's feedback
> - solve the circular dependency in the CONFIG_MDIO_DEVICE + CONFIG_PHYLIB case

Series applied, thanks Florian.
