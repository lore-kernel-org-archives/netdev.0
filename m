From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] net: mvpp2: optional PHYs and GoP link
 irq
Date: Fri, 01 Sep 2017 10:09:06 -0700 (PDT)
Message-ID: <20170901.100906.960417981534309612.davem@davemloft.net>
References: <20170901090455.32316-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901090455.32316-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Fri,  1 Sep 2017 11:04:51 +0200

> This series aims at making the driver work when no PHY is connected
> between a port and the physical layer and not described as a fixed-phy.
> This is useful for some usecases such as when a switch is connected
> directly to the serdes lanes. It can also be used for SFP ports on the
> 7k-db and 8k-db while waiting for the phylink support to land in (which
> should be part of another series).
> 
> This series makes the phy optional in the PPv2 driver, and then adds
> the support for the GoP port link interrupt to handle link status
> changes on such ports.
> 
> This was tested using the SFP ports on the 7k-db and 8k-db boards.

Series applied.
