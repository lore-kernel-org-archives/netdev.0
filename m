From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] wan: new driver retina
Date: Mon, 22 Oct 2007 08:02:19 -0700
Message-ID: <20071022080219.3a4c8664.rdunlap@xenotime.net>
References: <720714.25776.qm@web52011.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:48243 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751222AbXJVPC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 11:02:26 -0400
Received: from midway.site ([71.117.233.180]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 08:02:19 -0700
In-Reply-To: <720714.25776.qm@web52011.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Oct 2007 04:14:57 -0700 (PDT) Matti Linnanvuori wrote:

> From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
> 
> Retina G.703 and G.SHDSL driver.
> 
> Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
> ---

Hi,
Just a few basic questions...  I'm not reviewing any of the code parts.


> Fixed Kconfig and the body of the explanation.
> 
> diff -Napur 
> linux-2.6.23/drivers/net/wan/Kconfig 
> linux-2.6.24/drivers/net/wan/Kconfig
> --- linux-2.6.23/drivers/net/wan/Kconfig	2007-10-09 23:31:38.000000000 +0300
> +++ linux-2.6.24/drivers/net/wan/Kconfig	2007-10-22 13:54:55.383644167 +0300
> @@ -494,4 +494,15 @@ config SBNI_MULTILINE
>  
>  	  If unsure, say N.
>  
> +config RETINA
> +	tristate "Retina support"
> +	depends on m && PCI
> +	help
> +	  Driver for Retina C5400 and E2200 network cards, which
> +	  support G.703, G.SHDSL, Ethernet encapsulation and PCI.
> +
> +	  The driver will be compiled as a module: the
> +	  module will be called retina.

Why is the driver restricted/limited to module only?

> +
>  endif # WAN

> diff -Napur linux-2.6.23/drivers/net/wan/retina.c linux-2.6.24/drivers/net/wan/retina.c
> --- linux-2.6.23/drivers/net/wan/retina.c	1970-01-01 02:00:00.000000000 +0200
> +++ linux-2.6.24/drivers/net/wan/retina.c	2007-10-22 12:01:44.856033562 +0300
> @@ -0,0 +1,4503 @@
> +/* V1.2.4 */
> +
> +/* retina.c: */
> +

> +
> +#define DRV_NAME	"retina"
> +#define DRV_VERSION	"1.2.5"
> +#define DRV_RELDATE	"November 14, 2003"

huh?

> +#if !defined(__OPTIMIZE__)
> +#warning  You must compile this file with correct options.
> +#warning  See the last lines of the source file.
> +#error You have to compile this driver with "-O".
> +#endif

What defines __OPTIMIZE__ in the kernel build environment?


> diff -Napur linux-2.6.23/drivers/net/wan/retina.h linux-2.6.24/drivers/net/wan/retina.h
> --- linux-2.6.23/drivers/net/wan/retina.h	1970-01-01 02:00:00.000000000 +0200
> +++ linux-2.6.24/drivers/net/wan/retina.h	2007-10-22 12:01:44.856033562 +0300
> @@ -0,0 +1,164 @@
> diff -Napur linux-2.6.23/MAINTAINERS linux-2.6.24/MAINTAINERS
> --- linux-2.6.23/MAINTAINERS	2007-10-09 23:31:38.000000000 +0300
> +++ linux-2.6.24/MAINTAINERS	2007-10-22 11:50:13.190983316 +0300
> @@ -3149,6 +3149,11 @@ L:	reiserfs-devel@vger.kernel.org
>  W:	http://www.namesys.com
>  S:	Supported
>  
> +RETINA DRIVER
> +P:	Matti Linnanvuori
> +M:	mattilinnanvuori@yahoo.com

and what mailing list?

> +S:	Supported
> +
>  ROCKETPORT DRIVER
>  P:	Comtrol Corp.
>  W:	http://www.comtrol.com


---
~Randy
