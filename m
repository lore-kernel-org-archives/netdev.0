From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 09/13] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Thu, 24 Aug 2017 16:56:09 +0200
Message-ID: <20170824145609.GJ8022@lunn.ch>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824083823.16826-10-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2017 at 10:38:19AM +0200, Antoine Tenart wrote:
> This patch adds logic to reconfigure the comphy/gop when the link status
> change at runtime. This is very useful on boards such as the mcbin which
> have SFP and Ethernet ports connected to the same MAC port: depending on
> what the user connects the driver will automatically reconfigure the
> link mode.

Hi Antoine

I would expect each of these external Ethernet ports to have its own
Ethernet PHY. Don't you need to disconnect from one Ethernet phy and
connect to the other Ethernet PHY when you change external Ethernet
port?

	Andrew
