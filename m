From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: marvell: fix Marvell 88E1512 used in SGMII
 mode
Date: Wed, 11 Jan 2017 10:03:07 -0500 (EST)
Message-ID: <20170111.100307.1659171906235723077.davem@davemloft.net>
References: <E1cR5bt-0000O8-1T@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch,
        charles-antoine.couret@nexvision.fr,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: rmk+kernel@armlinux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50572 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764003AbdAKPDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:03:10 -0500
In-Reply-To: <E1cR5bt-0000O8-1T@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>
Date: Tue, 10 Jan 2017 23:13:45 +0000

> When an Marvell 88E1512 PHY is connected to a nic in SGMII mode, the
> fiber page is used for the SGMII host-side connection.  The PHY driver
> notices that SUPPORTED_FIBRE is set, so it tries reading the fiber page
> for the link status, and ends up reading the MAC-side status instead of
> the outgoing (copper) link.  This leads to incorrect results reported
> via ethtool.
> 
> If the PHY is connected via SGMII to the host, ignore the fiber page.
> However, continue to allow the existing power management code to
> suspend and resume the fiber page.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Applied, thanks Russell.
