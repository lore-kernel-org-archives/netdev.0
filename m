From: Brice Goglin <brice@myri.com>
Subject: Re: [patch 1/8] myri10ge: alpha build fix
Date: Fri, 09 Jun 2006 07:46:25 -0400
Message-ID: <44895F91.3010203@myri.com>
References: <200606090519.k595JfxP032014@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:21635 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S965239AbWFILrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 07:47:04 -0400
To: akpm@osdl.org
In-Reply-To: <200606090519.k595JfxP032014@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A similar fix is included in the myri10ge update that Jeff merged into
netdev yesterday.

thanks,
Brice



akpm@osdl.org wrote:
> From: Andrew Morton <akpm@osdl.org>
>
> drivers/net/myri10ge/myri10ge.c: In function 'myri10ge_submit_8rx':
> drivers/net/myri10ge/myri10ge.c:772: error: 'DMA_32BIT_MASK' undeclared (first use in this function)
> drivers/net/myri10ge/myri10ge.c:772: error: (Each undeclared identifier is reported only once
> drivers/net/myri10ge/myri10ge.c:772: error: for each function it appears in.)
> drivers/net/myri10ge/myri10ge.c: In function 'myri10ge_probe':
> drivers/net/myri10ge/myri10ge.c:2607: error: 'DMA_64BIT_MASK' undeclared (first use in this function)
> drivers/net/myri10ge/myri10ge.c:2612: error: 'DMA_32BIT_MASK' undeclared (first use in this function)
>
> Cc: Brice Goglin <brice@myri.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
>
>  drivers/net/myri10ge/myri10ge.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff -puN drivers/net/myri10ge/myri10ge.c~myri10ge-alpha-build-fix drivers/net/myri10ge/myri10ge.c
> --- devel/drivers/net/myri10ge/myri10ge.c~myri10ge-alpha-build-fix	2006-06-03 21:13:30.000000000 -0700
> +++ devel-akpm/drivers/net/myri10ge/myri10ge.c	2006-06-03 21:13:43.000000000 -0700
> @@ -59,6 +59,8 @@
>  #include <linux/crc32.h>
>  #include <linux/moduleparam.h>
>  #include <linux/io.h>
> +#include <linux/dma-mapping.h>
> +
>  #include <net/checksum.h>
>  #include <asm/byteorder.h>
>  #include <asm/io.h>
> _
>   

