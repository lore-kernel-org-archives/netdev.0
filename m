From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] PHYLIB: Kconfig: Fix the dependency on S390
Date: Thu, 22 May 2008 06:21:37 -0400
Message-ID: <48354931.1090007@pobox.com>
References: <Pine.LNX.4.55.0805170647110.4049@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59295 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936232AbYEVKVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:21:39 -0400
In-Reply-To: <Pine.LNX.4.55.0805170647110.4049@cliff.in.clinika.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maciej W. Rozycki wrote:
>  PHYLIB was first marked as BROKEN on S390, then the enclosing menu marked 
> as non-S390, then the two dependencies merged with the conversion to 
> menuconfig.  Reduce to non-S390.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
> patch-2.6.26-rc1-20080505-phy-s390-1
> diff -up --recursive --new-file linux-2.6.26-rc1-20080505.macro/drivers/net/phy/Kconfig linux-2.6.26-rc1-20080505/drivers/net/phy/Kconfig
> --- linux-2.6.26-rc1-20080505.macro/drivers/net/phy/Kconfig	2008-05-05 02:55:39.000000000 +0000
> +++ linux-2.6.26-rc1-20080505/drivers/net/phy/Kconfig	2008-05-17 05:57:43.000000000 +0000
> @@ -5,7 +5,7 @@
>  menuconfig PHYLIB
>  	tristate "PHY Device support and infrastructure"
>  	depends on !S390
> -	depends on NET_ETHERNET && (BROKEN || !S390)
> +	depends on NET_ETHERNET
>  	help

applied


