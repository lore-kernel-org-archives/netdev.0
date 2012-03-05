From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 0/6] stmmac: Driver Updates
Date: Mon, 05 Mar 2012 16:31:52 +0100
Message-ID: <4F54DC68.4050708@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: spear-devel@list.st.com, netdev@vger.kernel.org
To: Deepak SIKRI <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:45052 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964942Ab2CEPcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 10:32:31 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A32ED44F
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2012 15:32:26 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 360DE260D
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2012 15:32:26 +0000 (GMT)
In-Reply-To: <1330692928-30330-1-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Deepak

thanks for these patches.
I've just commented the patches #1 #2 #3.

I've found some problem when apply them in git.net.

I'll look at the patches #4 and #5 tomorrow and then I'll give you my
feedback. These have an impact on old driver versions too.

Patch #6, at first glance looks fine to me. I'll give you mu Acked-by as
soon as I complete the review.

Sorry for the delay

Regards
Peppe

On 3/2/2012 1:55 PM, Deepak SIKRI wrote:
> This patch set modifies the stmmac driver.
> Following changes have been done in the patch set.
> 1. Explicitly have the option to pass checksum offload engine type
> through the platform code. This is helpful for stmmac core prior to
> revision 3.5
> 2. Pass the default value of clk_csr scaling through the platform code.
> Define the scaling macros to be consistently used across driver and plat
> code.
> 3. Update the stmmac driver to incorporate the CPU freq framework.
> 4. Update the DMA descriptor status checks for cores prior to rev-3.5.
> 5. Configure burst related DMA parameter for cores revision beyond
> rev-3.6
> 6. Replace infinite loop in mdio read and write by timeouts
> 
> Deepak Sikri (6):
>   stmmac: Define CSUM offload engine Types
>   stmmac: Define MDC clock selection macros.
>   stmmac: Add support for CPU freq notifiers.
>   stmmac: Update stmmac descriptor checks for stmmac core prior to
>     Rev-3.5.
>   stmmac: configure burst related GMAC DMA parameters
>   stmmac: Replace infinite loops by timeouts in mdio r/w
> 
>  drivers/net/ethernet/stmicro/stmmac/common.h       |    2 +-
>  .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   14 ++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
>  drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   17 ++-
>  drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |    2 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   10 ++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  138 +++++++++++++++++++-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   30 ++++-
>  include/linux/stmmac.h                             |   36 +++++
>  9 files changed, 229 insertions(+), 21 deletions(-)
> 
> 
