From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: ethernet: bcmgenet: use
 phy_ethtool_{get|set}_link_ksettings"
Date: Mon, 11 Jul 2016 12:57:33 -0700 (PDT)
Message-ID: <20160711.125733.1619512909014032205.davem@davemloft.net>
References: <1468018487-8102-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468018487-8102-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  9 Jul 2016 00:54:47 +0200

> This reverts commit 4386f5662e63 ("net: ethernet: bcmgenet: use
> phy_ethtool_{get|set}_link_ksettings")
> 
> This patch is wrong, the function phy_ethtool_{get|set}_link_ksettings
> don't check if the device is running, but the driver bcmgenet need this
> check.
> 
> The function {get|set}_settings need to access the mdio bus, and this
> bus may only be used when the device is running. Otherwise, the clock
> is disable and a mdio access will fail.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
