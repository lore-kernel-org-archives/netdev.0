From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Revert "net: ethernet: bcmgenet: use
 phy_ethtool_{get|set}_link_ksettings"
Date: Fri, 8 Jul 2016 16:00:53 -0700
Message-ID: <578030A5.3060704@gmail.com>
References: <1468018487-8102-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468018487-8102-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/08/2016 03:54 PM, Philippe Reynes wrote:
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

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
-- 
Florian
