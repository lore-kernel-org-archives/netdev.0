From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] phy: fix blackfin build failure
Date: Sun, 10 Jan 2016 22:46:25 -0500 (EST)
Message-ID: <20160110.224625.2255348524619041283.davem@davemloft.net>
References: <1452252495-20961-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	andrew@lunn.ch
To: sudipm.mukherjee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452252495-20961-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Fri,  8 Jan 2016 16:58:14 +0530

> The build of blackfin defconfig is failing with the error:
> error: 'struct mii_bus' has no member named 'phy_map'
> 
> A new API mdiobus_get_phy() was introduced and phy_map was removed but
> it was not changed here.
> 
> Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus.")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

Applied.
