From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 00/13] net: mvpp2: comphy configuration
Date: Wed, 30 Aug 2017 15:18:24 -0700 (PDT)
Message-ID: <20170830.151824.2294408281974075576.davem@davemloft.net>
References: <20170830082924.3180-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kishon@ti.com, andrew@lunn.ch, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830082924.3180-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Wed, 30 Aug 2017 10:29:11 +0200

> This series, following up the one one the GoP/MAC configuration, aims at
> stopping to depend on the firmware/bootloader configuration when using
> the PPv2 engine. With this series the PPv2 driver does not need to rely
> on a previous configuration, and dynamic reconfiguration while the
> kernel is running can be done (i.e. switch one port from SGMII to 10G,
> or the opposite). A port can now be configured in a different mode than
> what's done in the firmware/bootloader as well.
> 
> The series first contain patches in the generic PHY framework to support
> what is called the comphy (common PHYs), which is an h/w block providing
> PHYs that can be configured in various modes ranging from SGMII, 10G
> to SATA and others. As of now only the SGMII and 10G modes are
> supported by the comphy driver.
> 
> Then patches are modifying the PPv2 driver to first add the comphy
> initialization sequence (i.e. calls to the generic PHY framework) and to
> then take advantage of this to allow dynamic reconfiguration (i.e.
> configuring the mode of a port given what's connected, between sgmii and
> 10G). Note the use of the comphy in the PPv2 driver is kept optional
> (i.e. if not described in dt the driver still as before an relies on the
> firmware/bootloader configuration).
> 
> Finally there are dt/defconfig patches to describe and take advantage of
> this.
> 
> This was tested on a range of devices: 8040-db, 8040-mcbin and 7040-db.
> 
> @Dave: the dt patches should go through the mvebu tree (patches 9-13).

Ok, patches 1-8 applied to net-next, thanks!
