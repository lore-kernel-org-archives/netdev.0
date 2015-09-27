From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ne: Add h8300 support.
Date: Sun, 27 Sep 2015 12:51:30 -0700 (PDT)
Message-ID: <20150927.125130.1749145249599569463.davem@davemloft.net>
References: <1443363556-29937-1-git-send-email-ysato@users.sourceforge.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ysato@users.sourceforge.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbbI0Tvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 15:51:33 -0400
In-Reply-To: <1443363556-29937-1-git-send-email-ysato@users.sourceforge.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoshinori Sato <ysato@users.sourceforge.jp>
Date: Sun, 27 Sep 2015 23:19:15 +0900

> @@ -88,7 +88,7 @@ config MCF8390
>  config NE2000
>  	tristate "NE2000/NE1000 support"
>  	depends on (ISA || (Q40 && m) || M32R || MACH_TX49XX || \
> -		    ATARI_ETHERNEC)
> +		    ATARI_ETHERNEC || H8300)
...
>  
> -#if  defined(CONFIG_PLAT_MAPPI) || defined(CONFIG_PLAT_OAKS32R)
> +#if  defined(CONFIG_PLAT_MAPPI) || defined(CONFIG_PLAT_OAKS32R) || \
> +	defined(CONFIG_H8300_KANEBEBE) || defined(CONFIG_H8300_AE3069)

It makes no sense to test different config symbols for these two
things.

Either both should use "H8300" or both should use
"H8300_KANEBEBE || H8300_AE3069".
