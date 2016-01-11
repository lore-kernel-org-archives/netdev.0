From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ethernet: broadcom: Fix build errors
Date: Sun, 10 Jan 2016 22:06:00 -0500 (EST)
Message-ID: <20160110.220600.1571134071098680158.davem@davemloft.net>
References: <1452456196-1624-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452456196-1624-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Sun, 10 Jan 2016 12:03:16 -0800

> Commit 7f854420fbfe ("phy: Add API for {un}registering an mdio device to
> a bus") introduces an API to access mii_bus structures, but missed to
> update the sb1250 driver. This results in the following build error.
> 
> drivers/net/ethernet/broadcom/sb1250-mac.c: In function 'sbmac_mii_probe':
> drivers/net/ethernet/broadcom/sb1250-mac.c:2360:24: error:
> 	'struct mii_bus' has no member named 'phy_map'
> 
> Use phy_find_first() instead of open coding it.
> 
> Commit 2220943a21e2 ("phy: Centralise print about attached phy") introduces
> the following build error.
> 
> drivers/net/ethernet/broadcom/sb1250-mac.c: In function 'sbmac_mii_probe':
> drivers/net/ethernet/broadcom/sb1250-mac.c:2383:20: error: 'phydev' undeclared
> 
> Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus")
> Fixes: 2220943a21e2 ("phy: Centralise print about attached phy")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied.
