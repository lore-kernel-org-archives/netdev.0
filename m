From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: Set valid phy interface type
Date: Tue, 17 Feb 2015 10:37:58 -0800 (PST)
Message-ID: <20150217.103758.934788051050893871.davem@davemloft.net>
References: <1424150631-22396-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbBQSam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 13:30:42 -0500
In-Reply-To: <1424150631-22396-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Mon, 16 Feb 2015 21:23:51 -0800

> If the phy interface mode is not found in devicetree, or if devicetree
> is not configured, of_get_phy_mode returns -ENODEV. The current code
> sets the phy interface mode to the return value from of_get_phy_mode
> without checking if it is valid.
> 
> This invalid phy interface mode is passed as parameter to of_phy_connect
> or to phy_connect_direct. This sets the phy interface mode to the invalid
> value, which in turn causes problems for any code using phydev->interface.
> 
> Fixes: b31f65fb4383 ("net: dsa: slave: Fix autoneg for phys on switch MDIO bus")
> Fixes: 0d8bcdd383b8 ("net: dsa: allow for more complex PHY setups")
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.
