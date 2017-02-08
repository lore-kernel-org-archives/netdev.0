From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 06/16] net: stmmac: fix some code style problem
Date: Wed, 08 Feb 2017 02:41:58 -0800
Message-ID: <1486550518.27834.13.camel@perches.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
         <20170208083121.27949-7-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-7-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-02-08 at 09:31 +0100, Corentin Labbe wrote:
> Checkpatch complains about some code style problem on stmmac_mdio.c.
> This patch fix them.
[]
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
[]
> @@ -258,6 +258,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>  	found = 0;
>  	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
>  		struct phy_device *phydev = mdiobus_get_phy(new_bus, addr);
> +
>  		if (phydev) {
>  			int act = 0;
>  			char irq_num[4];

Maybe use
		if (!phydev)
			continue;
to reduce indentation
