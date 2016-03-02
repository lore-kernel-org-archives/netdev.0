From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v3 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Wed, 2 Mar 2016 12:33:09 -0600
Message-ID: <20160302183309.GA2449@rob-hp-laptop>
References: <1456483912-32090-1-git-send-email-alexandre.torgue@gmail.com>
 <1456483912-32090-3-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: Alexandre TORGUE <alexandre.torgue@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456483912-32090-3-git-send-email-alexandre.torgue@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 26, 2016 at 11:51:50AM +0100, Alexandre TORGUE wrote:
> Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>
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
> +	       "snps,dwmac-3.50a" to select IP vesrion.
> +- clocks: Should contain the GMAC main clock, and tx clock
> +- compatible:  Should be "st,stm32-dwmac" to select glue and
> +	       "snps,dwmac-3.50a" to select IP version.
> +- clocks: Should contain the MAC main clock
> +- clock-names: Should contain the clock names "stmmaceth".
> +- st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
> +	      encompases the glue register, and the offset of the control register.
> +
> +Optional properties:
> +- clocks: Could contain:
> +	- the tx clock,
> +	- the rx clock
> +- clock-names: Could contain the clock names "tx-clk", "rx-clk"

Either the IP block has 3 clocks or it has 1. If you have a case where 1 
clock feeds all 3 inputs, then list the clock 3 times.

Rob
