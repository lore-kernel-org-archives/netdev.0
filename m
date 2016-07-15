From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: ti: cpmac: use
 phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 16:44:25 -0700 (PDT)
Message-ID: <20160715.164425.1846268495169830717.davem@davemloft.net>
References: <1468579142-14138-1-git-send-email-tremyfr@gmail.com>
	<1468579142-14138-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468579142-14138-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 15 Jul 2016 12:39:02 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> There was a check on CAP_NET_ADMIN in cpmac_set_settings, but this
> check is already done in dev_ethtool, so no need to repeat it before
> calling the generic function.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
