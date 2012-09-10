From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net] ixp4xx_hss: fix build failure after logging
 conversion
Date: Mon, 10 Sep 2012 18:04:25 +0100
Message-ID: <1347296665.2823.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <1347266590-884-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <khc@pm.waw.pl>, <joe@perches.com>,
	David Miller <davem@davemloft.net>, <stable@vger.kernel.org>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38689 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750891Ab2IJRE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 13:04:29 -0400
In-Reply-To: <1347266590-884-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 10:43 +0200, Florian Fainelli wrote:
> Commit c75bb2c6f0cf455c23e60f14d780e841dd47f801 (ixp4xx_hss: Update to
> current logging forms) converted the ixp4xx_hss module to use the current
> logging macros, but forgot to include linux/module.h, leading to the
> following build failures:
> 
>   CC [M]  drivers/net/wan/ixp4xx_hss.o
>  drivers/net/wan/ixp4xx_hss.c:1412:20: error: expected ';', ',' or ')'
>  before string constant
>  drivers/net/wan/ixp4xx_hss.c:1413:25: error: expected ';', ',' or ')'
>  before string constant
>  drivers/net/wan/ixp4xx_hss.c:1414:21: error: expected ';', ',' or ')'
>  before string constant
>  drivers/net/wan/ixp4xx_hss.c:1415:19: error: expected ';', ',' or ')'
>  before string constant
>  make[8]: *** [drivers/net/wan/ixp4xx_hss.o] Error 1
> 
> CC: stable@vger.kernel.org
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
> [stable: 3.1+]

The versions to receive stable updates should be noted on the inline Cc
line, not in non-committed comments.  (But David prefers to collect up
networking patches in his own stable queue rather than using the inline
Cc mechanism.  So the Cc may not be appropriate at all.)

Ben.

>  drivers/net/wan/ixp4xx_hss.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
> index aaaca9a..3f575af 100644
> --- a/drivers/net/wan/ixp4xx_hss.c
> +++ b/drivers/net/wan/ixp4xx_hss.c
> @@ -10,6 +10,7 @@
>  
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
> +#include <linux/module.h>
>  #include <linux/bitops.h>
>  #include <linux/cdev.h>
>  #include <linux/dma-mapping.h>

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
