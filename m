From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [patch net-next] stmmac: indent an if statement
Date: Thu, 12 Jan 2017 20:46:05 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1701122045460.1988@hadrien>
References: <20170112184631.GA12157@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        jpinto <Joao.Pinto@synopsys.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112184631.GA12157@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 12 Jan 2017, Dan Carpenter wrote:

> The break statement should be indented one more tab.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index ac32f9e..4daa8a3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -191,7 +191,7 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
>  		for_each_child_of_node(np, plat->mdio_node) {
>  			if (of_device_is_compatible(plat->mdio_node,
>  						    "snps,dwmac-mdio"))
> -			break;
> +				break;

If there is a break, there is probably also a need for an of_node_put?

julia

>  		}
>  	}
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
