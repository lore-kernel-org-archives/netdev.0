From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/4] net-next: mediatek: add platform data to
 adapt into various hardware
Date: Mon, 17 Jul 2017 15:43:09 +0200
Message-ID: <20170717134309.GB30392@lunn.ch>
References: <cover.1500285278.git.sean.wang@mediatek.com>
 <2987b7e3b40cfcd143b5da444c6722b5e92bc0b5.1500285278.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@phrozen.org, davem@davemloft.net, nbd@openwrt.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mediatek@lists.infradead.org
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2987b7e3b40cfcd143b5da444c6722b5e92bc0b5.1500285278.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  const struct of_device_id of_mtk_match[] = {
> -	{ .compatible = "mediatek,mt2701-eth" },
> +	{ .compatible = "mediatek,mt2701-eth", .data = &mt2701_data},
> +	{ .compatible = "mediatek,mt7623-eth", .data = &mt7623_data},
>  	{},

Hi Sean

The binding document also lists "mediatek,mt7622-eth"?

    Andrew
