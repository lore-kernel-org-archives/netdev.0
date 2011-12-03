From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH] ARM: at91/net: add macb ethernet controller in 9g45 DT
Date: Sat, 3 Dec 2011 06:56:59 +0100
Message-ID: <20111203055659.GL18533@game.jcrosoft.org>
References: <1322847782-22650-1-git-send-email-nicolas.ferre@atmel.com>
 <1322848237-23154-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, grant.likely@secretlab.ca, jamie@jamieiles.com,
 linux-arm-kernel@lists.infradead.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1322848237-23154-1-git-send-email-nicolas.ferre@atmel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 18:50 Fri 02 Dec     , Nicolas Ferre wrote:
> Add the Cadence macb ethernet controller in at91sam9g45 .dtsi and
> enable it in at91sam9m10g45ek board device tree file.
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
>  arch/arm/boot/dts/at91sam9g45.dtsi     |    7 +++++++
>  arch/arm/boot/dts/at91sam9m10g45ek.dts |    6 ++++++
>  2 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/at91sam9g45.dtsi b/arch/arm/boot/dts/at91sam9g45.dtsi
> index e89b1d7..67f94d3 100644
> --- a/arch/arm/boot/dts/at91sam9g45.dtsi
> +++ b/arch/arm/boot/dts/at91sam9g45.dtsi
> @@ -101,6 +101,13 @@
>  				atmel,use-dma-tx;
>  				status = "disabled";
>  			};
> +
> +			macb0: ethernet@fffbc000 {
> +				compatible = "cdns,at32ap7000-macb", "cdns,macb";
> +				reg = <0xfffbc000 0x100>;
> +				interrupts = <25 4>;
why?
> +				status = "disabled";
> +			};
>  		};
>  	};
>  };
> diff --git a/arch/arm/boot/dts/at91sam9m10g45ek.dts b/arch/arm/boot/dts/at91sam9m10g45ek.dts
> index 85b34f5..17377a2 100644
> --- a/arch/arm/boot/dts/at91sam9m10g45ek.dts
> +++ b/arch/arm/boot/dts/at91sam9m10g45ek.dts
> @@ -30,6 +30,12 @@
>  			usart1: serial@fff90000 {
>  				status = "okay";
>  			};
> +
> +			macb0: ethernet@fffbc000 {
> +				local-mac-address = [3a 0e 03 04 05 06];
please drop this is not supposed to be in the dts but updated for each board

Best Regards,
J.
