From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/4] net: mvpp2: make the phy optional
Date: Fri, 1 Sep 2017 15:34:34 +0200
Message-ID: <20170901133434.GX22289@lunn.ch>
References: <20170901090455.32316-1-antoine.tenart@free-electrons.com>
 <20170901090455.32316-3-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170901090455.32316-3-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2017 at 11:04:53AM +0200, Antoine Tenart wrote:
> There is not necessarily a PHY between the GoP and the physical port.
> However, the driver currently makes the "phy" property mandatory,
> contrary to what is stated in the device tree bindings. This patch makes
> the PHY optional, and aligns the PPv2 driver on its device tree
> documentation. However if a PHY is provided, the GoP link interrupt
> won't be used.
> 
> With this patch switches directly connected to the serdes lanes and SFP
> ports on the Armada 8040-db and Armada 7040-db can be used if the link
> interrupt is described in the device tree.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> Tested-by: Marcin Wojtas <mw@semihalf.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
