From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net-next) v3] net: stmmac: fix warning from Sparse for
 socfpga
Date: Thu, 28 Aug 2014 07:53:54 +0200
Message-ID: <53FEC3F2.3010809@st.com>
References: <1409201986-3514-1-git-send-email-lftan@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <lftan.linux@gmail.com>, Vince Bridgers <vbridger@altera.com>
To: Ley Foon Tan <lftan@altera.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409201986-3514-1-git-send-email-lftan@altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/28/2014 6:59 AM, Ley Foon Tan wrote:
> Warning:
> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:122:41:
> sparse: cast removes address space of expression
> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:122:38:
> sparse: incorrect type in assignment (different address spaces)
>
> Signed-off-by: Ley Foon Tan <lftan@altera.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> index cd613d7..ddc6115 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> @@ -119,8 +119,7 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
>   			return -EINVAL;
>   		}
>
> -		dwmac->splitter_base = (void *)devm_ioremap_resource(dev,
> -			&res_splitter);
> +		dwmac->splitter_base = devm_ioremap_resource(dev, &res_splitter);
>   		if (!dwmac->splitter_base) {
>   			dev_info(dev, "Failed to mapping emac splitter\n");
>   			return -EINVAL;
>
