From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] stmicro: add more information to Kconfig
Date: Fri, 20 Jan 2017 16:00:03 +0000
Message-ID: <b059a971-7d5b-4ec7-dbcf-6cc33a7a8946@synopsys.com>
References: <8e4b7bbd48a0b2ff1374fdffe6d07dc00659e951.1484664500.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <rayagond@vayavyalabs.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:57853 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752373AbdATQJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:09:59 -0500
In-Reply-To: <8e4b7bbd48a0b2ff1374fdffe6d07dc00659e951.1484664500.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


My e-mail client went bogus, please ignore 2 past e-mails.
Very sorry.

Best Regards,
Joao Pinto

Às 3:57 PM de 1/20/2017, Joao Pinto escreveu:
> This patch adds more info to stmicro' Kconfig files in order to be clearer
> that the driver can be used by ethernet cards based on 10/100/1000/EQOS
> Synopsys IP Cores.
> 
> EQOS was also added stmmac/Kconfig Kconfig, since dwmac4 is in fact EQoS,
> one of Synopsys Ethernet IPs. More info at:
> https://www.synopsys.com/dw/ipdir.php?ds=dwc_ether_qos
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
>  drivers/net/ethernet/stmicro/Kconfig        |  3 ++-
>  drivers/net/ethernet/stmicro/stmmac/Kconfig | 15 +++++++--------
>  2 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/Kconfig b/drivers/net/ethernet/stmicro/Kconfig
> index 1c1157d..ecd7a5e 100644
> --- a/drivers/net/ethernet/stmicro/Kconfig
> +++ b/drivers/net/ethernet/stmicro/Kconfig
> @@ -7,7 +7,8 @@ config NET_VENDOR_STMICRO
>  	default y
>  	depends on HAS_IOMEM
>  	---help---
> -	  If you have a network (Ethernet) card belonging to this class, say Y.
> +	  If you have a network (Ethernet) card based on Synopsys Ethernet IP
> +	  Cores, say Y.
>  
>  	  Note that the answer to this question doesn't directly affect the
>  	  kernel: saying N will just cause the configurator to skip all
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> index 99594e3..cfbe363 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
> +++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> @@ -1,5 +1,5 @@
>  config STMMAC_ETH
> -	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
> +	tristate "STMicroelectronics 10/100/1000/EQOS Ethernet driver"
>  	depends on HAS_IOMEM && HAS_DMA
>  	select MII
>  	select PHYLIB
> @@ -7,9 +7,8 @@ config STMMAC_ETH
>  	imply PTP_1588_CLOCK
>  	select RESET_CONTROLLER
>  	---help---
> -	  This is the driver for the Ethernet IPs are built around a
> -	  Synopsys IP Core and only tested on the STMicroelectronics
> -	  platforms.
> +	  This is the driver for the Ethernet IPs built around a
> +	  Synopsys IP Core.
>  
>  if STMMAC_ETH
>  
> @@ -152,11 +151,11 @@ config STMMAC_PCI
>  	tristate "STMMAC PCI bus support"
>  	depends on STMMAC_ETH && PCI
>  	---help---
> -	  This is to select the Synopsys DWMAC available on PCI devices,
> -	  if you have a controller with this interface, say Y or M here.
> +	  This selects the platform specific bus support for the stmmac driver.
> +	  This driver was tested on XLINX XC2V3000 FF1152AMT0221
> +	  D1215994A VIRTEX FPGA board and SNPS QoS IPK Prototyping Kit.
>  
> -	  This PCI support is tested on XLINX XC2V3000 FF1152AMT0221
> -	  D1215994A VIRTEX FPGA board.
> +	  If you have a controller with this interface, say Y or M here.
>  
>  	  If unsure, say N.
>  endif
> 
