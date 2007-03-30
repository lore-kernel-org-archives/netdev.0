From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.21-rc5-mm3: fix e1000 compilation
Date: Fri, 30 Mar 2007 07:39:04 -0700
Message-ID: <460D2108.1080101@intel.com>
References: <20070330085029.GA6556@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21808 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbXC3OjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 10:39:07 -0400
In-Reply-To: <20070330085029.GA6556@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
>   CC [M]  drivers/net/e1000/e1000_main.o
> drivers/net/e1000/e1000_main.c: In function 'e1000_tso':
> drivers/net/e1000/e1000_main.c:2968: error: dereferencing pointer to incomplete type
> 	...
> 

can you send me your config? I'd like to see why nobody here didn't spot this on 
any of our tests.

thanks,

Auke


> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -32,6 +32,8 @@ #include <linux/init.h>
>  #include <linux/vmalloc.h>
>  #include <linux/pagemap.h>
>  #include <linux/netdevice.h>
> +#include <linux/tcp.h>
> +#include <linux/ipv6.h>
>  #include <net/checksum.h>
>  #include <net/ip6_checksum.h>
>  #include <linux/mii.h>
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
