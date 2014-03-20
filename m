From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] of_mdio: Allow the DT to specify the phy ID and
 avoid autoprobing
Date: Thu, 20 Mar 2014 17:10:57 -0400 (EDT)
Message-ID: <20140320.171057.609753569047907079.davem@davemloft.net>
References: <1395267324-5788-1-git-send-email-jgunthorpe@obsidianresearch.com>
	<1395267324-5788-2-git-send-email-jgunthorpe@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jgunthorpe@obsidianresearch.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395267324-5788-2-git-send-email-jgunthorpe@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Date: Wed, 19 Mar 2014 16:15:24 -0600

> This makes the generic of_mdiobus_register parse the DT compatible string for
> the pattern ethernet-phy-idAAAA.BBBB. If present it should be a value that
> matches the phy-id register normally readable through MDIO.
> 
> When the ID is given the phy autoprobing is defeated and the phy is
> created directly.
> 
> This is necessary to support phy's that cannot be autoprobed when
> of_mdiobus_register is called. Specifically, my case has the phy in reset at
> of_mdiobus_register, the reset is only released once the ethernet driver
> starts, before it attaches to the phy.
> 
> Tested on ARM Kirkwood with phy id 0x01410e90 (Marvell 88E1318)
> 
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Also applied to net-next.
