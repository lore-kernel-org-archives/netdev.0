From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [2.6 patch] NET_SCH_ATM doesn't need ipcommon.o
Date: Mon, 27 Nov 2006 06:04:37 +0000
Message-ID: <20061127060437.GA2682@infradead.org>
References: <20061127005934.GN15364@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas@cmf.nrl.navy.mil, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:20899 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1757060AbWK0GFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 01:05:10 -0500
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20061127005934.GN15364@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 27, 2006 at 01:59:34AM +0100, Adrian Bunk wrote:
> NET_SCH_ATM doesn't need ipcommon.o
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> --- linux-2.6.19-rc6-mm1/net/atm/Makefile.old	2006-11-26 08:50:05.000000000 +0100
> +++ linux-2.6.19-rc6-mm1/net/atm/Makefile	2006-11-26 08:56:29.000000000 +0100
> @@ -10,7 +10,6 @@
>  atm-$(subst m,y,$(CONFIG_ATM_CLIP)) += ipcommon.o
>  obj-$(CONFIG_ATM_BR2684) += br2684.o
>  atm-$(subst m,y,$(CONFIG_ATM_BR2684)) += ipcommon.o
> -atm-$(subst m,y,$(CONFIG_NET_SCH_ATM)) += ipcommon.o

Btw, ages ago Dave said there plans to get rid of ipcommon.c (it's just
a single function).  Did anything ever happen towards those plans?
