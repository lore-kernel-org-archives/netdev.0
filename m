From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH-next] net: ethernet: mediatek: fix implicit irq include
 causing build fails
Date: Sun, 23 Jul 2017 17:16:40 +0200
Message-ID: <faa87d84-936f-8f09-0653-933ee6cccabc@phrozen.org>
References: <20170723145613.14007-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>,
        Sean Wang <sean.wang@mediatek.com>, linux-next@vger.kernel.org,
        linux-mediatek@lists.infradead.org,
        Matthias Brugger <matthias.bgg@gmail.com>,
        John Crispin <blogic@openwrt.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>,
        netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170723145613.14007-1-paul.gortmaker@windriver.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul

mark sent the same patch a couple of days ago [1]

     John

[1] https://patchwork.ozlabs.org/patch/791550/


On 23/07/17 16:56, Paul Gortmaker wrote:
> To fix:
>
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:1685:1: error: unknown type name 'irqreturn_t'
> drivers/net/ethernet/mediatek/mtk_eth_soc.c: In function 'mtk_handle_irq_rx':
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:1694:9: error: 'IRQ_HANDLED' undeclared (first use in this function)
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:1694:9: note: each undeclared identifier is reported only once for each function it appears in
>
> and similar follow-on errors as seen in arm allmodconfig builds.
>
> Cc: Sean Wang <sean.wang@mediatek.com>
> Cc: Felix Fietkau <nbd@openwrt.org>
> Cc: John Crispin <blogic@openwrt.org>
> Cc: Matthias Brugger <matthias.bgg@gmail.com>
> Cc: linux-mediatek@lists.infradead.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>
> [Seen on current linux-next, where similar implicit irq includes
>   were recently revealed by some header shuffle somewhere.]
>
>   drivers/net/ethernet/mediatek/mtk_eth_soc.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 7e95cf547ff1..ea15eb095d83 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -16,6 +16,7 @@
>   #include <linux/of_mdio.h>
>   #include <linux/of_net.h>
>   #include <linux/mfd/syscon.h>
> +#include <linux/interrupt.h>
>   #include <linux/regmap.h>
>   #include <linux/clk.h>
>   #include <linux/pm_runtime.h>
