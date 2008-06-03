From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC] Make board force selection of PHYLIB
Date: Tue, 3 Jun 2008 20:00:22 +0300
Message-ID: <20080603170022.GE9605@cs181133002.pp.htv.fi>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org> <48442239.7090906@garzik.org> <BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org> <83820D83-487C-4586-9867-F4226A87A276@freescale.com> <48445851.4090105@garzik.org> <095F258F-72DD-4F27-A457-A57D9FAA1E76@kernel.crashing.org> <48448020.5020407@freescale.com> <Pine.LNX.4.64.0806030945540.21537@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:44309 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753200AbYFCRAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 13:00:49 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806030945540.21537@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 09:47:19AM -0500, Kumar Gala wrote:
> How is this as a fix.
> 
> - k
> 
> diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
> index 7ff29d5..9e5c884 100644
> --- a/arch/powerpc/platforms/85xx/Kconfig
> +++ b/arch/powerpc/platforms/85xx/Kconfig
> @@ -34,6 +34,7 @@ config MPC85xx_MDS
>  	bool "Freescale MPC85xx MDS"
>  	select DEFAULT_UIMAGE
>  	select QUICC_ENGINE
> +	select PHYLIB if GIANFAR=m
>  	help
>  	  This option enables support for the MPC85xx MDS board

The .config you sent me as an example didn't have GIANFAR set, so it 
couldn't help there.

How early do the fixups have to run?

I see two possible solutions:
- let MPC85xx_MDS unconditionally select PHYLIB or
- move the fixups to the gianfar driver

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

