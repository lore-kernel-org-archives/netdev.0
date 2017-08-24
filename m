From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 02/13] phy: add the mvebu cp110 comphy driver
Date: Thu, 24 Aug 2017 15:45:04 +0200
Message-ID: <20170824134504.GD8022@lunn.ch>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-3-antoine.tenart@free-electrons.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42976 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752681AbdHXNpK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 09:45:10 -0400
Content-Disposition: inline
In-Reply-To: <20170824083823.16826-3-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	for_each_available_child_of_node(pdev->dev.of_node, child) {
> +		struct mvebu_comphy_lane *lane;
> +		struct phy *phy;
> +		int ret;
> +		u32 val;
> +
> +		ret = of_property_read_u32(child, "reg", &val);
> +		if (ret < 0) {
> +			dev_err(&pdev->dev, "missing 'reg' property (%d)\n",
> +				ret);
> +			continue;
> +		}

I'm just wondering why we need this. We know how many lanes there are
from the table. So just create a generic PHY for each lane?

     Andrew
