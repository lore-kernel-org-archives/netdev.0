From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net-next 1/5] net: stmmac: Implement ethtool::nway_reset
Date: Thu, 17 Nov 2016 17:38:38 +0100
Message-ID: <53bc6ffe-77ef-09bd-de91-1b744c52cf16@st.com>
References: <20161115191949.15361-1-f.fainelli@gmail.com>
 <20161115191949.15361-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <andrew@lunn.ch>, <tremyfr@gmail.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115191949.15361-2-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/2016 8:19 PM, Florian Fainelli wrote:
> Utilize the generic phy_ethtool_nway_reset() helper function to
> implement an autonegotiation restart.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> index 3fe9340b748f..0290d52330da 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> @@ -870,6 +870,7 @@ static const struct ethtool_ops stmmac_ethtool_ops = {
>  	.get_regs = stmmac_ethtool_gregs,
>  	.get_regs_len = stmmac_ethtool_get_regs_len,
>  	.get_link = ethtool_op_get_link,
> +	.nway_reset = phy_ethtool_nway_reset,
>  	.get_pauseparam = stmmac_get_pauseparam,
>  	.set_pauseparam = stmmac_set_pauseparam,
>  	.get_ethtool_stats = stmmac_get_ethtool_stats,
>
