From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH RESEND net-next 3/3] arm64: hip05-d02: Document
 devicetree bindings for Hisilicon D02 Board
Date: Mon, 7 Dec 2015 07:16:17 -0600
Message-ID: <20151207131617.GA25170@rob-hp-laptop>
References: <1449302088-53037-1-git-send-email-yankejian@huawei.com>
 <1449302088-53037-4-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	xuwei5@hisilicon.com, catalin.marinas@arm.com, will.deacon@arm.com,
	wangkefeng.wang@huawei.com, dingtianhong@huawei.com,
	liguozhu@huawei.com, Yisen.Zhuang@huawei.com, sboyd@codeaurora.org,
	haojian.zhuang@linaro.org, wangzhou1@hisilicon.com,
	bintian.wang@huawei.com, long.wanglong@huawei.com,
	leo.yan@linaro.org, haifeng.wei@huawei.com,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linuxarm@huawei.com
To: yankejian <yankejian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:59999 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754655AbbLGNQX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 08:16:23 -0500
Content-Disposition: inline
In-Reply-To: <1449302088-53037-4-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 05, 2015 at 03:54:48PM +0800, yankejian wrote:
> This patch adds documentation for the devicetree bindings used by the
> DT files of Hisilicon Hip05-D02 development board.
> 
> Signed-off-by: yankejian <yankejian@huawei.com>
> ---
>  .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt b/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
> index 6ac7c00..5318d78 100644
> --- a/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
> +++ b/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
> @@ -187,6 +187,22 @@ Example:
>  		reg = <0xb0000000 0x10000>;
>  	};
>  
> +Hisilicon HiP05 PERISUB system controller
> +
> +Required properties:
> +- compatible : "hisilicon,peri-c-subctrl", "syscon";

This should be more specific and have the SOC name in it.

> +- reg : Register address and size
> +
> +The HiP05 PERISUB system controller is shared by peripheral controllers in
> +HiP05 Soc to implement some basic configurations. the peripheral
> + controllers include mdio, ddr, iic, uart, timer and so on.
> +
> +Example:
> +	/* for HiP05 PCIe-SAS system */
> +	pcie_sas: system_controller@0xb0000000 {
> +		compatible = "hisilicon,pcie-sas-subctrl", "syscon";

The example doesn't match.

> +		reg = <0xb0000000 0x10000>;
> +	};
>  -----------------------------------------------------------------------
>  Hisilicon CPU controller
>  
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
