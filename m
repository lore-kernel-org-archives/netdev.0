From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [POWERPC] 85xx: MPC85xx MDS - Unconditionally select
 PHYLIB for board fixups
Date: Fri, 06 Jun 2008 13:48:44 -0400
Message-ID: <4849787C.8090506@garzik.org>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org> <20080602165422.GA22051@cs181133002.pp.htv.fi> <Pine.LNX.4.64.0806021423380.11043@blarg.am.freescale.net> <Pine.LNX.4.64.0806061039390.13744@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <adrian.bunk@movial.fi>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57611 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753314AbYFFRss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2008 13:48:48 -0400
In-Reply-To: <Pine.LNX.4.64.0806061039390.13744@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
> The MPC85xx MDS board requires some board level tweaks of the PHYs that
> either the eTSEC (gianfar) or UCC ethernet controllers are connected to.
> 
> Its possible to build the phylib as a module, however this breaks the
> board level fix ups because phy_read and phy_write are not available
> if we build as a module.
> 
> So we unconditionally select PHYLIB to ensure its built into the kernel
> if we are building in MPC85xx MDS support.  This was determined to be
> the easiest soultion even though it prevents the user from removing
> PHYLIB support if they decide they don't want it.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> ---
> 
> will go via the powerpc.git tree for 2.6.26.
> 
> - k
> 
>  arch/powerpc/platforms/85xx/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
> index 7ff29d5..ecbe580 100644
> --- a/arch/powerpc/platforms/85xx/Kconfig
> +++ b/arch/powerpc/platforms/85xx/Kconfig
> @@ -34,6 +34,7 @@ config MPC85xx_MDS
>  	bool "Freescale MPC85xx MDS"
>  	select DEFAULT_UIMAGE
>  	select QUICC_ENGINE
> +	select PHYLIB
>  	help

ACK


