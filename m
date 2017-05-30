From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/2] net: phy: Support managed Cortina phys
Date: Tue, 30 May 2017 12:42:58 -0400 (EDT)
Message-ID: <20170530.124258.552928885307723573.davem@davemloft.net>
References: <1496049091-4637-1-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: bogdan.purcareata@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496049091-4637-1-git-send-email-bogdan.purcareata@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Date: Mon, 29 May 2017 09:11:29 +0000

> So far, the Cortina family phys (CS4340 in this particular case) are only
> supported in fixed link mode (via fixed_phy_register). The generic 10G
> phy driver does not work well with the phylib state machine, when the phy
> is registered via of_phy_connect. This prohibits the user from describing the
> phy nodes in the device tree.
> 
> In order to support this scenario, and to properly describe the board
> device tree, add a minimal Cortina driver that reads the status from the
> right register. With the generic 10G C45 driver, the kernel will print
> messages like:
> [    0.226521] mdio_bus 8b96000: Error while reading PHY16 reg at 1.6
> [    0.232780] mdio_bus 8b96000: Error while reading PHY16 reg at 1.5
 ...

Series applied, thanks.
