From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 2/3] drivers: net: ethernet: stmmac: fix failure in module
 test
Date: Tue, 22 May 2012 14:51:09 +0200
Message-ID: <4FBB8BBD.8010208@st.com>
References: <1337672336-7378-1-git-send-email-lliubbo@gmail.com> <1337672336-7378-2-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, francesco.virlinzi@st.com,
	rayagond@vayavyalabs.com, sr@denx.de, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: Bob Liu <lliubbo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:41579 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754200Ab2EVMvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 08:51:54 -0400
In-Reply-To: <1337672336-7378-2-git-send-email-lliubbo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/22/2012 9:38 AM, Bob Liu wrote:
> Module can't be compiled and installed in current Makefile.

I've just seen that I can generate the stmmac.ko on ARM and also on x86
with my configuration.

Can you post here you build failure?

In the meantime I'll test the module on ARM soon.

peppe

> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/Makefile |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
> index bc965ac..4b50922 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
> @@ -1,10 +1,10 @@
>  obj-$(CONFIG_STMMAC_ETH) += stmmac.o
> -stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
> -stmmac-$(CONFIG_STMMAC_RING) += ring_mode.o
> -stmmac-$(CONFIG_STMMAC_CHAINED) += chain_mode.o
> -stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
> -stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
> +stmmac-$(CONFIG_STMMAC_TIMER:m=y) += stmmac_timer.o
> +stmmac-$(CONFIG_STMMAC_RING:m=y) += ring_mode.o
> +stmmac-$(CONFIG_STMMAC_CHAINED:m=y) += chain_mode.o
> +stmmac-$(CONFIG_STMMAC_PLATFORM:m=y) += stmmac_platform.o
> +stmmac-$(CONFIG_STMMAC_PCI:m=y) += stmmac_pci.o
>  stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
>  	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
>  	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
> -	      mmc_core.o $(stmmac-y)
> +	      mmc_core.o
