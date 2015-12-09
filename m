From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 net-next 3/3] bindings: ethernet: macb: Add optional
 caps properties
Date: Tue, 8 Dec 2015 21:49:51 -0600
Message-ID: <20151209034951.GA23712@rob-hp-laptop>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
 <1449582726-6148-1-git-send-email-narmstrong@baylibre.com>
 <1449582726-6148-4-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.ferre@atmel.com, davem@davemloft.net,
	harini.katakam@xilinx.com, boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org, joshc@ni.com
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449582726-6148-4-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 08, 2015 at 02:52:06PM +0100, Neil Armstrong wrote:
> Add generic caps properties to the binding in order to support
> future macb/gem implementations with the generic macb compatible form.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Acked-by: Rob Herring <robh@kernel.org>

> ---
>  Documentation/devicetree/bindings/net/macb.txt | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
> index b5d7976..891c72e 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -19,6 +19,16 @@ Required properties:
>  	Optional elements: 'tx_clk'
>  - clocks: Phandles to input clocks.
>  
> +Optional properties:
> +- cdns,usrio-has-clken: Boolean; The USRIO register has an clock-enable bit.
> +- cdns,usrio-default-mii: Boolean; The USRIO register defaults to MII mode.
> +- cdns,usrio-disabled: Boolean; The USRIO register is not implemented.
> +- cdns,no-gigabit-half: Boolean; The MAC does not support 1000/Half link mode.
> +- cdns,gem-sg-disabled: Boolean; The MAC does not support Scatter-Gather mode.
> +- cdns,gem-has-gigabit: Boolean; The MAC supports Gigabit Ethernet.
> +- cdns,dma-burst-length: Should countain the DMA burst length.
> +- cdns,jumbo-max-length: Should countain the maximum Jumbo frame length.
> +
>  Examples:
>  
>  	macb0: ethernet@fffc4000 {
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
