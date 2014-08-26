From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net-next) v2] net: stmmac: fix warning from Sparse for
 socfpga
Date: Tue, 26 Aug 2014 12:13:35 +0200
Message-ID: <53FC5DCF.4060202@st.com>
References: <1409046479-18546-1-git-send-email-lftan@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <lftan.linux@gmail.com>, Vince Bridgers <vbridger@altera.com>
To: Ley Foon Tan <lftan@altera.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:39457 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932235AbaHZKNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 06:13:50 -0400
In-Reply-To: <1409046479-18546-1-git-send-email-lftan@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/26/2014 11:47 AM, Ley Foon Tan wrote:
> Warning:
> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:122:41:
> sparse: cast removes address space of expression
> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:122:38:
> sparse: incorrect type in assignment (different address spaces)
>
> Signed-off-by: Ley Foon Tan <lftan@altera.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> index cd613d7..ff54a1f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> @@ -119,7 +119,7 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
>   			return -EINVAL;
>   		}
>
> -		dwmac->splitter_base = (void *)devm_ioremap_resource(dev,
> +		dwmac->splitter_base = devm_ioremap_resource(dev,
>   			&res_splitter);

can the ioremap call stay in a single line ? or pls review indent looks
NOK

peppe

>   		if (!dwmac->splitter_base) {
>   			dev_info(dev, "Failed to mapping emac splitter\n");
>
