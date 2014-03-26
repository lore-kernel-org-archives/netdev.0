From: Gerhard Sittig <gsi@denx.de>
Subject: Re: [PATCH 2/3] dts: socfpga: Fix ethernet entries for the stmmac
Date: Wed, 26 Mar 2014 23:12:25 +0100
Message-ID: <20140326221225.GP3998@book.gsilab.sittig.org>
References: <1395790482-3957-1-git-send-email-dinguyen@altera.com>
 <1395790482-3957-3-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dinh.linux@gmail.com, arnd@arndb.de, davem@davemloft.net,
	peppe.cavallaro@st.com, mark.rutland@arm.com,
	devicetree@vger.kernel.org, pawel.moll@arm.com,
	srinivas.kandagatla@st.com, netdev@vger.kernel.org,
	ijc+devicetree@hellion.org.uk, robh+dt@kernel.org, arm@kernel.org,
	galak@codeaurora.org, linux-arm-kernel@lists.infradead.org
To: dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:49053 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbaCZWMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 18:12:32 -0400
Content-Disposition: inline
In-Reply-To: <1395790482-3957-3-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-25 at 18:34 -0500, dinguyen@altera.com wrote:
> 
> -			#size-cells = <1>;
> -			compatible = "altr,socfpga-stmmac";
> -			altr,sysmgr-syscon = <&sysmgr 0x60>;
> +		gmac0: ethernet@ff700000 {
> +			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
>  			status = "disabled";
> -			ranges;
> -
> -			gmac0: gmac0@ff700000 {
> -				compatible = "snps,dwmac-3.70a", "snps,dwmac";
> -				reg = <0xff700000 0x2000>;
> -				interrupts = <0 115 4>;
> -				interrupt-names = "macirq";
> -				mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
> -				clocks = <&emac0_clk>;
> -				clock-names = "stmmaceth";
> -			};
> +			altr,sysmgr-syscon = <&sysmgr 0x60>;
> +			reg = <0xff700000 0x2000>;
> +			interrupts = <0 115 4>;
> +			interrupt-names = "macirq";
> +			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
> +			clocks = <&emac0_clk>;
> +			clock-names = "stmmaceth";
>  		};

not strictly related to this patch, but noticed in bypassing:

is the 'clocks' spec correct?  ISTR that 'emac0_clk' is the PLL
output, while the gated clock for the EMAC IP block is named
'emac_0_clk' (note the extra underscore)


virtually yours
Gerhard Sittig
-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr. 5, D-82194 Groebenzell, Germany
Phone: +49-8142-66989-0 Fax: +49-8142-66989-80  Email: office@denx.de
