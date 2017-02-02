From: James Liao <jamesjj.liao@mediatek.com>
Subject: Re: [PATCH 2/2] net-next: ethernet: mediatek: change the compatible
 string
Date: Thu, 2 Feb 2017 13:07:29 +0800
Message-ID: <1486012049.25978.1.camel@mtksdaap41>
References: <1485332455-34743-1-git-send-email-john@phrozen.org>
         <1485332455-34743-2-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sean Wang <sean.wang@mediatek.com>,
        <linux-mediatek@lists.infradead.org>, <devicetree@vger.kernel.org>
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:25471 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750871AbdBBFHe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 00:07:34 -0500
In-Reply-To: <1485332455-34743-2-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 09:20 +0100, John Crispin wrote:
> When the binding was defined, I was not aware that mt2701 was an earlier
> version of the SoC. For sake of consistency, the ethernet driver should
> use mt2701 inside the compat string as this is the earliest SoC with the
> ethernet core.
> 
> The ethernet driver is currently of no real use until we finish and
> upstream the DSA driver. There are no users of this binding yet. It should
> be safe to fix this now before it is too late and we need to provide
> backward compatibility for the mt7623-eth compat string.
> 
> Reported-by: Sean Wang <sean.wang@mediatek.com>
> Signed-off-by: John Crispin <john@phrozen.org>

Acked-by: James Liao <jamesjj.liao@mediatek.com>

> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 25ae0c5..9e75768 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -2515,7 +2515,7 @@ static int mtk_remove(struct platform_device *pdev)
>  }
>  
>  const struct of_device_id of_mtk_match[] = {
> -	{ .compatible = "mediatek,mt7623-eth" },
> +	{ .compatible = "mediatek,mt2701-eth" },
>  	{},
>  };
>  MODULE_DEVICE_TABLE(of, of_mtk_match);
