From: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Fri, 26 Feb 2016 18:57:53 +0100
Message-ID: <CAGhQ9VyQTfYbqcZ7pYzwmhcj8FZ+FZ51ciexOLC-9ZhU4eKT2A@mail.gmail.com>
References: <1456483912-32090-1-git-send-email-alexandre.torgue@gmail.com>
	<1456483912-32090-3-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Alexandre TORGUE <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1456483912-32090-3-git-send-email-alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alexandre,

On 26 February 2016 at 11:51, Alexandre TORGUE
<alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Signed-off-by: Alexandre TORGUE <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> diff --git a/Documentation/devicetree/bindings/net/stm32-dwmac.txt b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
> new file mode 100644
> index 0000000..67fceda
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
> @@ -0,0 +1,40 @@
> +STMicroelectronics STM32 / MCU DWMAC glue layer controller
> +
> +This file documents platform glue layer for stmmac.
> +Please see stmmac.txt for the other unchanged properties.
> +
> +The device node has following properties.
> +
> +Required properties:
> +- compatible:  Should be "st,stm32-dwmac" to select glue, and
> +              "snps,dwmac-3.50a" to select IP vesrion.
> +- clocks: Should contain the GMAC main clock, and tx clock
> +- compatible:  Should be "st,stm32-dwmac" to select glue and
> +              "snps,dwmac-3.50a" to select IP version.
> +- clocks: Should contain the MAC main clock
> +- clock-names: Should contain the clock names "stmmaceth".
> +- st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
> +             encompases the glue register, and the offset of the control register.
> +
> +Optional properties:
> +- clocks: Could contain:
> +       - the tx clock,
> +       - the rx clock
> +- clock-names: Could contain the clock names "tx-clk", "rx-clk"
> +
> +Example:
> +
> +               ethernet0: dwmac@40028000 {
> +                       compatible = "st,stm32-dwmac", "snps,dwmac-3.50a";
> +                       status = "disabled";
> +                       reg = <0x40028000 0x8000>;
> +                       reg-names = "stmmaceth";
> +                       interrupts = <0 61 0>, <0 62 0>;
> +                       interrupt-names = "macirq", "eth_wake_irq";
> +                       clock-names = "stmmaceth", "tx-clk", "rx-clk";
> +                       clocks = <&rcc 0 25>, <&rcc 0 26>, <&rcc 0 27>;
> +                       st,syscon = <&syscfg 0x4>;
> +                       snps,pbl = <8>;
> +                       snps,mixed-burst;
> +                       dma-ranges;
> +               };

Looks just like any other dwmac-driver binding so:

Acked-by: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


regards,
Joachim Eastwood
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
