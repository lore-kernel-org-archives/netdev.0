From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 09/13] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Thu, 24 Aug 2017 19:45:19 +0200
Message-ID: <20170824174519.GC18700@lunn.ch>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch>
 <20170824165947.GZ20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824165947.GZ20805@n2100.armlinux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Russell

> I think you're all getting confused.

Yes, i was at least.

> The 88x3310 driver in the kernel knows about these combinations and
> sets the phy interface parameter correctly depending on whether the
> PHY has configured itself for copper at whatever speed or SFP+.

So when the PHY decides to swap from copper to fibre etc, is the
phylib state machine kept up to date. Does it see a down, followed by
an up?

   Andrew
