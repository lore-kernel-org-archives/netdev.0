From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 14/17] net: stmmac: print phy information
Date: Tue, 31 Jan 2017 11:10:04 +0100
Message-ID: <734d7c1c-bf82-c723-59b8-2abd003dc6d7@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-15-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170131091152.13842-15-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> When a PHY is found, printing which one was found (and which type/model) is
> a good information to know.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index e53b727..3d52b8c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -885,6 +885,7 @@ static int stmmac_init_phy(struct net_device *dev)
>  	netdev_dbg(priv->dev, "%s: attached to PHY (UID 0x%x) Link = %d\n",
>  		   __func__, phydev->phy_id, phydev->link);
>
> +	phy_attached_info(phydev);

maybe we could remove the netdev_dbg above and just keep
phy_attached_info(phydev);

peppe

>  	return 0;
>  }
>
>
