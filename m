From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET-NEXT PATCH] e1000: remove unused Kconfig option for disabling
 packet split
Date: Wed, 03 Sep 2008 09:59:08 -0400
Message-ID: <48BE982C.20705@garzik.org>
References: <20080827081956.11114.152.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43505 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752032AbYICN7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 09:59:14 -0400
In-Reply-To: <20080827081956.11114.152.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Since the e1000/e1000e split, no hardware supported by e1000
> supports packet split, just remove the Kconfig option and associated
> code from arch/* and the driver.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  arch/arm/configs/iop13xx_defconfig              |    1 
>  arch/arm/configs/iop32x_defconfig               |    1 
>  arch/arm/configs/iop33x_defconfig               |    1 
>  arch/arm/configs/ixp23xx_defconfig              |    1 
>  arch/arm/configs/kirkwood_defconfig             |    1 
>  arch/ia64/configs/generic_defconfig             |    1 
>  arch/ia64/configs/gensparse_defconfig           |    1 
>  arch/ia64/configs/tiger_defconfig               |    1 
>  arch/ia64/configs/zx1_defconfig                 |    1 
>  arch/mips/configs/mtx1_defconfig                |    1 
>  arch/parisc/configs/a500_defconfig              |    1 
>  arch/parisc/configs/c3000_defconfig             |    1 
>  arch/powerpc/configs/83xx/mpc832x_rdb_defconfig |    1 
>  arch/powerpc/configs/85xx/mpc8560_ads_defconfig |    1 
>  arch/powerpc/configs/85xx/mpc85xx_cds_defconfig |    1 
>  arch/powerpc/configs/85xx/tqm8548_defconfig     |    1 
>  arch/powerpc/configs/cell_defconfig             |    1 
>  arch/powerpc/configs/g5_defconfig               |    1 
>  arch/powerpc/configs/iseries_defconfig          |    1 
>  arch/powerpc/configs/maple_defconfig            |    1 
>  arch/powerpc/configs/pasemi_defconfig           |    1 
>  arch/powerpc/configs/ppc64_defconfig            |    1 
>  arch/powerpc/configs/ppc6xx_defconfig           |    1 
>  arch/powerpc/configs/prpmc2800_defconfig        |    1 
>  arch/powerpc/configs/pseries_defconfig          |    1 
>  arch/sh/configs/r7780mp_defconfig               |    1 
>  arch/sparc64/defconfig                          |    1 
>  arch/x86/configs/i386_defconfig                 |    1 
>  arch/x86/configs/x86_64_defconfig               |    1 
>  drivers/net/Kconfig                             |    9 
>  drivers/net/e1000/e1000.h                       |   17 -
>  drivers/net/e1000/e1000_main.c                  |  416 -----------------------
>  32 files changed, 9 insertions(+), 462 deletions(-)

ACK, except for the defconfig changes.  arch maintainers usually prefer 
to do that themselves.

We'd be continually patch defconfig files, if we did so every time it 
was likely one would be updated by a Kconfig patch.


