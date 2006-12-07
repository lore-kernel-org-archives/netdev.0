From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETLINK]: Restore API compatibility of address and neighbour
	bits
Date: Thu, 07 Dec 2006 11:28:28 +0000
Message-ID: <1165490908.5253.275.camel@pmac.infradead.org>
References: <200612062033.34754.stefan@loplof.de>
	 <20061206.165638.30168567.davem@davemloft.net>
	 <20061207104721.GI8693@postel.suug.ch>
	 <20061207.025140.75779834.davem@davemloft.net>
	 <20061207105502.GJ8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stefan@loplof.de,
	joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51988 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032054AbWLGL2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 06:28:37 -0500
To: Thomas Graf <tgraf@suug.ch>, stable@kernel.org
In-Reply-To: <20061207105502.GJ8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-07 at 11:55 +0100, Thomas Graf wrote:
> Restore API compatibility due to bits moved from rtnetlink.h to
> separate headers.

For 2.6.19.1 too, please.

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Index: net-2.6/include/linux/rtnetlink.h
> ===================================================================
> --- net-2.6.orig/include/linux/rtnetlink.h	2006-12-07 11:25:29.000000000 +0100
> +++ net-2.6/include/linux/rtnetlink.h	2006-12-07 11:32:25.000000000 +0100
> @@ -3,6 +3,8 @@
>  
>  #include <linux/netlink.h>
>  #include <linux/if_link.h>
> +#include <linux/if_addr.h>
> +#include <linux/neighbour.h>
>  
>  /****
>   *		Routing/neighbour discovery messages.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
dwmw2

