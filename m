From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 14/17] net: stmmac: print phy information
Date: Fri, 3 Feb 2017 14:16:03 +0100
Message-ID: <20170203131603.GA3653@Red>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-15-clabbe.montjoie@gmail.com>
 <734d7c1c-bf82-c723-59b8-2abd003dc6d7@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexandre.torgue@st.com, netdev@vger.kernel.org,
        davem@davemloft.net, linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <734d7c1c-bf82-c723-59b8-2abd003dc6d7@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 31, 2017 at 11:10:04AM +0100, Giuseppe CAVALLARO wrote:
> On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> > When a PHY is found, printing which one was found (and which type/model) is
> > a good information to know.
> >
> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > ---
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > index e53b727..3d52b8c 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > @@ -885,6 +885,7 @@ static int stmmac_init_phy(struct net_device *dev)
> >  	netdev_dbg(priv->dev, "%s: attached to PHY (UID 0x%x) Link = %d\n",
> >  		   __func__, phydev->phy_id, phydev->link);
> >
> > +	phy_attached_info(phydev);
> 
> maybe we could remove the netdev_dbg above and just keep
> phy_attached_info(phydev);
> 
> peppe
> 

Ok, I will remove it

Regards
Corentin Labbe
