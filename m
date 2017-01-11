From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Wed, 11 Jan 2017 12:00:36 +0800
Message-ID: <40521f32-436d-b31d-92a4-4cff97f3411d@synopsys.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <CARLOS.PALMINHA@synopsys.com>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:58472 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752723AbdAKEA6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 23:00:58 -0500
In-Reply-To: <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joao,


On 2017/1/10 22:52, Joao Pinto wrote:
> This patch renames stmicro/stmmac to synopsys/ since it is a standard
> ethernet software package regarding synopsys ethernet controllers, supporting
> the majority of Synopsys Ethernet IPs. The config IDs remain the same, for
> retro-compatibility, only the description was changed.
>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
> changes v1->v2:
> - nothing changed. Just to keep up with patch set version
>
> @@ -1,5 +1,5 @@
>  config STMMAC_ETH
> -	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
> +	tristate "Synopsys Ethernet drivers"
>  	depends on HAS_IOMEM && HAS_DMA
>  	select MII
>  	select PHYLIB
> @@ -14,7 +14,7 @@ config STMMAC_ETH
>  if STMMAC_ETH
>  
"Synopsys Ethernet drivers" is too generic. The name should reflect the
controller. This driver is for Synopsys GMAC 10M/100M/1G IPs. We will submit a
driver for the new 25G/40G/50G/100G XLGMAC IP in the future.
>  config STMMAC_PLATFORM
> -	tristate "STMMAC Platform bus support"
> +	tristate "Platform bus support"
>  	depends on STMMAC_ETH
>  	select MFD_SYSCON
>  	default y
> @@ -149,13 +149,13 @@ config DWMAC_SUNXI
>  endif
>  
>  config STMMAC_PCI
> -	tristate "STMMAC PCI bus support"
> +	tristate "PCI bus support"
>  	depends on STMMAC_ETH && PCI
>  	---help---
>  	  This is to select the Synopsys DWMAC available on PCI devices,
>  	  if you have a controller with this interface, say Y or M here.
>  
> -	  This PCI support is tested on XLINX XC2V3000 FF1152AMT0221
> +	  This PCI support was tested on XLINX XC2V3000 FF1152AMT0221
>  	  D1215994A VIRTEX FPGA board.
The name is also too generic. Please try to reflect the controller.

Thanks,
Jie
