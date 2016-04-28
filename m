From: Maxime Coquelin <mcoquelin.stm32@gmail.com>
Subject: Re: [PATCH v6 5/6] ARM: dts: stm32f429: Align Ethernet node with new
 bindings properties
Date: Thu, 28 Apr 2016 14:01:17 +0200
Message-ID: <CALszF6D4Uzqtw7GCmxTRpB7S8AGwnoj3uf36SywzDxV6Gg8iBw@mail.gmail.com>
References: <1461585242-32401-1-git-send-email-alexandre.torgue@gmail.com>
	<1461585242-32401-6-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>, wens@csie.org
To: Alexandre TORGUE <alexandre.torgue@gmail.com>,
	Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461585242-32401-6-git-send-email-alexandre.torgue@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alex,

2016-04-25 13:54 GMT+02:00 Alexandre TORGUE <alexandre.torgue@gmail.com>:
> This patch aligns clocks names and node reference according to new
> stm32-dwmac glue binding. It also renames Ethernet pinctrl phandle
> (indeed there is no need to add 0 as Ethernet instance as there is only
> one IP in SOC).
>
> Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>
>
> diff --git a/arch/arm/boot/dts/stm32f429.dtsi b/arch/arm/boot/dts/stm32f429.dtsi
> index 35df462..5995998 100644
> --- a/arch/arm/boot/dts/stm32f429.dtsi
> +++ b/arch/arm/boot/dts/stm32f429.dtsi
> @@ -304,7 +304,7 @@
>                                 };
>                         };
>
> -                       ethernet0_mii: mii@0 {
> +                       ethernet_mii: mii@0 {
>                                 pins {
>                                         pinmux = <STM32F429_PG13_FUNC_ETH_MII_TXD0_ETH_RMII_TXD0>,
>                                                  <STM32F429_PG14_FUNC_ETH_MII_TXD1_ETH_RMII_TXD1>,
> @@ -363,13 +363,13 @@
>                         st,mem2mem;
>                 };
>
> -               ethernet0: dwmac@40028000 {
> +               mac: ethernet@40028000 {
>                         compatible = "st,stm32-dwmac", "snps,dwmac-3.50a";
>                         reg = <0x40028000 0x8000>;
>                         reg-names = "stmmaceth";
>                         interrupts = <61>, <62>;
>                         interrupt-names = "macirq", "eth_wake_irq";
> -                       clock-names = "stmmaceth", "tx-clk", "rx-clk";
> +                       clock-names = "stmmaceth", "mac-clk-tx", "mac-clk-rx";

It looks good to me, but I will wait for Rob's ack on the bindings
documentation patch before applying it.

Regards,
Maxime
