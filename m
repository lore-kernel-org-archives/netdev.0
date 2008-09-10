From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 4/4] atlx: update build files for atl2
Date: Tue, 09 Sep 2008 22:24:09 -0400
Message-ID: <48C72FC9.10308@redhat.com>
References: <20080909061247.GA17834@file.rdu.redhat.com>	<20080909062441.GD18425@file.rdu.redhat.com> <20080909204702.340c2205@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	atl2-test@lists.sourceforge.net
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33910 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736AbYIJC1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 22:27:52 -0400
In-Reply-To: <20080909204702.340c2205@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> On Tue, 9 Sep 2008 02:24:41 -0400
> Chris Snook <csnook@redhat.com> wrote:
> 
>> From: Chris Snook <csnook@redhat.com>
>>
>> Add the Kconfig and Makefile entries for atl2.  Also remove the
>> EXPERIMENTAL label from atl1, as it is now quite mature.
>>
>> Signed-off-by: Chris Snook <csnook@redhat.com>
> 
> Patch doesn't apply against current Linus' git.  Also, this is a Fast
> Ethernet device, so it probably shouldn't be in the 1000 Mbit Kconfig
> section.  This patch fixes it.

Oops.  Brain gets tired after thousands of lines of whitespace cleanup.  Thanks 
for fixing it.

Acked-by: Chris Snook <csnook@redhat.com>

> commit f4b4f597e623ffae70947844a8e6431a58502439
> Author: Jay Cliburn <jacliburn@bellsouth.net>
> Date:   Tue Sep 9 20:31:58 2008 -0500
> 
>     atl2: kconfig and makefile changes for atl2
>     
>     Add Kconfig and Makefile changes to merge the atl2 driver.
>     
>     Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 4a11296..81a3e95 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1840,6 +1840,17 @@ config NE_H8300
>           Say Y here if you want to use the NE2000 compatible
>           controller on the Renesas H8/300 processor.
>  
> +config ATL2
> +       tristate "Atheros L2 Fast Ethernet support"
> +       depends on PCI
> +       select CRC32
> +       select MII
> +       help
> +         This driver supports the Atheros L2 fast ethernet adapter.
> +
> +         To compile this driver as a module, choose M here.  The module
> +         will be called atl2.
> +
>  source "drivers/net/fs_enet/Kconfig"
>  
>  endif # NET_ETHERNET
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 7629c90..eda7b12 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -15,6 +15,7 @@ obj-$(CONFIG_EHEA) += ehea/
>  obj-$(CONFIG_CAN) += can/
>  obj-$(CONFIG_BONDING) += bonding/
>  obj-$(CONFIG_ATL1) += atlx/
> +obj-$(CONFIG_ATL2) += atlx/
>  obj-$(CONFIG_ATL1E) += atl1e/
>  obj-$(CONFIG_GIANFAR) += gianfar_driver.o
>  obj-$(CONFIG_TEHUTI) += tehuti.o
> diff --git a/drivers/net/atlx/Makefile b/drivers/net/atlx/Makefile
> index ca45553..e4f6022 100644
> --- a/drivers/net/atlx/Makefile
> +++ b/drivers/net/atlx/Makefile
> @@ -1 +1,3 @@
>  obj-$(CONFIG_ATL1)     += atl1.o
> +obj-$(CONFIG_ATL2)     += atl2.o
> +
> 

