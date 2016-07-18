From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: adi: bfin_mac: use
 phy_ethtool_{get|set}_link_ksettings
Date: Sun, 17 Jul 2016 23:22:51 -0700 (PDT)
Message-ID: <20160717.232251.1118461470001037366.davem@davemloft.net>
References: <1468710615-31951-1-git-send-email-tremyfr@gmail.com>
	<1468710615-31951-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, sudipm.mukherjee@gmail.com, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, treding@nvidia.com, fw@strlen.de,
	linux@roeck-us.net, adi-buildroot-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468710615-31951-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 17 Jul 2016 01:10:15 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> There was a check on CAP_NET_ADMIN in bfin_mac_ethtool_setsettings,
> but this check is already done in dev_ethtool, so no need to repeat
> it before calling the generic function.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
