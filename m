From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v2 06/16] net: stmmac: fix some code style problem
Date: Wed, 8 Feb 2017 16:06:45 +0100
Message-ID: <20170208150645.GA11421@Red>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
 <20170208083121.27949-7-clabbe.montjoie@gmail.com>
 <1486550518.27834.13.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1486550518.27834.13.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2017 at 02:41:58AM -0800, Joe Perches wrote:
> On Wed, 2017-02-08 at 09:31 +0100, Corentin Labbe wrote:
> > Checkpatch complains about some code style problem on stmmac_mdio.c.
> > This patch fix them.
> []
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> []
> > @@ -258,6 +258,7 @@ int stmmac_mdio_register(struct net_device *ndev)
> >  	found = 0;
> >  	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
> >  		struct phy_device *phydev = mdiobus_get_phy(new_bus, addr);
> > +
> >  		if (phydev) {
> >  			int act = 0;
> >  			char irq_num[4];
> 
> Maybe use
> 		if (!phydev)
> 			continue;
> to reduce indentation

Thanks I will do it in a subsequent patch

Regards
Corentin Labbe
