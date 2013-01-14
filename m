From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: remove flags argument from
 phy_{attach,connect,connect_direct}
Date: Mon, 14 Jan 2013 15:12:14 -0500 (EST)
Message-ID: <20130114.151214.1296751187134652417.davem@davemloft.net>
References: <1358160772-29631-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, konszert@marvell.com, afleming@gmail.com,
	linux-kernel@vger.kernel.org
To: florian@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358160772-29631-1-git-send-email-florian@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <florian@openwrt.org>
Date: Mon, 14 Jan 2013 11:52:52 +0100

> The flags argument of the phy_{attach,connect,connect_direct} functions
> is then used to assign a struct phy_device dev_flags with its value.
> All callers but the tg3 driver pass the flag 0, which results in the
> underlying PHY drivers in drivers/net/phy/ not being able to actually
> use any of the flags they would set in dev_flags. This patch gets rid of
> the flags argument, and passes phydev->dev_flags to the internal PHY
> library call phy_attach_direct() such that drivers which actually modify
> a phy device dev_flags get the value preserved for use by the underlying
> phy driver.
> 
> Acked-by: Kosta Zertsekel <konszert@marvell.com>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied, thanks.
