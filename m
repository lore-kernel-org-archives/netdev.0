From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: pch_gbe depends on x86_32
Date: Fri, 16 May 2014 06:16:01 -0700
Message-ID: <1400246161.7973.162.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140516112904.7072da0f@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
	"David S. Miller" <davem@davemloft.net>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:40826 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763AbaEPNQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 09:16:04 -0400
Received: by mail-pb0-f42.google.com with SMTP id md12so2624118pbc.1
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 06:16:03 -0700 (PDT)
In-Reply-To: <20140516112904.7072da0f@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 11:29 +0200, Jean Delvare wrote:
> The pch_gbe driver is for a companion chip to the Intel Atom E600
> series processors. These are 32-bit x86 processors so the driver is
> only needed on X86_32.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Cc: Jiri Slaby <jslaby@suse.cz>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/oki-semi/pch_gbe/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-3.15-rc5.orig/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig	2014-03-31 05:40:15.000000000 +0200
> +++ linux-3.15-rc5/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig	2014-05-16 11:20:28.453261606 +0200
> @@ -4,7 +4,7 @@
>  
>  config PCH_GBE
>  	tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
> -	depends on PCI && (X86 || COMPILE_TEST)
> +	depends on PCI && (X86_32 || COMPILE_TEST)
>  	select MII
>  	select PTP_1588_CLOCK_PCH
>  	---help---
> 
> 

Although its always nice to be able to compile it with x86_64 host,
to make sure we do not add regressions when we change something in a
core networking part.
