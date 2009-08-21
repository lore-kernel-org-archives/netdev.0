From: =?ISO-8859-1?Q?Richard_R=F6jfors?=
	<richard.rojfors.ext@mocean-labs.com>
Subject: Re: [PATCH] Fix Micrel KSZ8842 Kconfig description
Date: Fri, 21 Aug 2009 12:36:49 +0200
Message-ID: <4A8E78C1.20409@mocean-labs.com>
References: <20090821102033.GA26577@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av7-1-sn3.vrr.skanova.net ([81.228.9.181]:33562 "EHLO
	av7-1-sn3.vrr.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582AbZHULIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 07:08:30 -0400
In-Reply-To: <20090821102033.GA26577@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Mohr wrote:
> Hi,
> 
> when doing a "make oldconfig" recently, non-descriptive item "Micrel KSZ8842"
> came up, and when I hit "?" to get more info, all I got was a tight-lipped
> "This platform driver is for Micrel KSZ8842 chip.".

I see your pain

> 
> Thanks,
> 
> Andreas Mohr
> 
> Signed-off-by: Andreas Mohr <andi@lisas.de>
> 
> --- linux-2.6.31-rc6/drivers/net/Kconfig.orig	2009-08-21 12:00:31.000000000 +0200
> +++ linux-2.6.31-rc6/drivers/net/Kconfig	2009-08-21 12:09:13.000000000 +0200
> @@ -1727,7 +1727,8 @@ config KS8842
>  	tristate "Micrel KSZ8842"
>  	depends on HAS_IOMEM
>  	help
> -	  This platform driver is for Micrel KSZ8842 chip.
> +	  This platform driver is for Micrel KSZ8842 / KS8842
> +	  2-port ethernet switch chip (managed, VLAN, QoS, PCI-based).

Remove "PCI-based"

This is a platform device, it is not PCI based.
The KS8842 can sit behind PCI, ISA or VLB, this driver basically 
supports the ISA mappings.

--Richard
