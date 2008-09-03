From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH -next] hp-plus: fix link objects
Date: Wed, 03 Sep 2008 10:08:53 -0400
Message-ID: <48BE9A75.9000401@pobox.com>
References: <20080902130344.d8847b3d.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan@lxorguk.ukuu.org.uk
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43719 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754727AbYICOI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:08:56 -0400
In-Reply-To: <20080902130344.d8847b3d.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix hp-plus Makefile object file:
> 
> drivers/built-in.o: In function `hpp_open':
> hp-plus.c:(.text+0xaf445): undefined reference to `ei_interrupt'
> hp-plus.c:(.text+0xaf4ac): undefined reference to `ei_open'
> drivers/built-in.o: In function `hpp_close':
> hp-plus.c:(.text+0xaf59d): undefined reference to `ei_close'
> drivers/built-in.o: In function `hpp_probe1':
> hp-plus.c:(.init.text+0x7314): undefined reference to `ei_poll'
> drivers/built-in.o: In function `hp_plus_probe':
> (.init.text+0x7407): undefined reference to `__alloc_ei_netdev'
> make[1]: *** [.tmp_vmlinux1] Error 1
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  drivers/net/Makefile |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-next-20080902.orig/drivers/net/Makefile
> +++ linux-next-20080902/drivers/net/Makefile
> @@ -111,7 +111,7 @@ obj-$(CONFIG_EL2) += 3c503.o 8390p.o
>  obj-$(CONFIG_NE2000) += ne.o 8390p.o
>  obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
>  obj-$(CONFIG_HPLAN) += hp.o 8390p.o
> -obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
> +obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390.o
>  obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
>  obj-$(CONFIG_ULTRAMCA) += smc-mca.o 8390.o
>  obj-$(CONFIG_ULTRA32) += smc-ultra32.o 8390.o

applied


