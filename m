From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 1/4] dt-bindings: net: mediatek: add support
 for MediaTek MT7623 and MT7622 SoC
Date: Mon, 17 Jul 2017 15:38:11 +0200
Message-ID: <20170717133811.GA30392@lunn.ch>
References: <cover.1500285278.git.sean.wang@mediatek.com>
 <d1e8daa3291f303bd581b89eae6e4003f2ee58a8.1500285278.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@phrozen.org, davem@davemloft.net, nbd@openwrt.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mediatek@lists.infradead.org
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d1e8daa3291f303bd581b89eae6e4003f2ee58a8.1500285278.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2017 at 06:06:22PM +0800, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> The patch adds the supplements in the dt-binding document for MediaTek
> MT7622 SoC with extra SGMII system controller and relevant clock consumers
> listed as the requirements for those SoCs equipped with the SGMII circuit.
> Also, add the missing binding information for MT7623 SoC here which relies
> on the fallback binding of MT2701.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> ---
>  Documentation/devicetree/bindings/net/mediatek-net.txt | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
> index c7194e8..1d1168b 100644
> --- a/Documentation/devicetree/bindings/net/mediatek-net.txt
> +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
> @@ -7,24 +7,30 @@ have dual GMAC each represented by a child node..
>  * Ethernet controller node
>  
>  Required properties:
> -- compatible: Should be "mediatek,mt2701-eth"
> +- compatible: Should be
> +		"mediatek,mt2701-eth": for MT2701 SoC
> +		"mediatek,mt7623-eth", "mediatek,mt2701-eth": for MT7623 SoC

Hi Sean

We appear to have "mediatek,mt2701-eth" twice.

   Andrew
