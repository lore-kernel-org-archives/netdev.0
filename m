From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next v2] net: bfin_mac: Fix build error due to missed
 API change
Date: Sun, 10 Jan 2016 16:45:32 +0100
Message-ID: <20160110154532.GB22229@lunn.ch>
References: <1452438484-29205-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	=adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452438484-29205-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2016 at 07:08:04AM -0800, Guenter Roeck wrote:
> Commit 7f854420fbfe ("phy: Add API for {un}registering an mdio device to
> a bus") introduces an API to access mii_bus structures, but missed to
> update the bfin_mac driver. This results in the following error message
> 
> drivers/net/ethernet/adi/bfin_mac.c: In function 'mii_probe':
> drivers/net/ethernet/adi/bfin_mac.c:401:52: error:
> 	'struct mii_bus' has no member named 'phy_map'
> 
> Use phy_find_first() instead of open-coding it.
> 
> Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Andrew Lunn <andrew@lunn.ch>

Hi Dave

Although Sadip Mukerjee's patch [PATCH 1/2] phy: fix blackfin build failure
is correct, this one is better. Please take this one in preference. 
We do still however need Sadip's [2/2] bfin_mac: fix error path

   Andrew
