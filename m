From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: issue request_irq after the private data are completely initialized
Date: Mon, 2 Apr 2007 22:30:14 +0200
Message-ID: <20070402203014.GA22652@electric-eye.fr.zoreil.com>
References: <20070402201112.GA22153@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56351 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965824AbXDBUc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 16:32:56 -0400
Content-Disposition: inline
In-Reply-To: <20070402201112.GA22153@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 521b5f0..990699f 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -64,8 +64,10 @@ VERSION 2.2LK	<2005/01/25>
>  #include <linux/ip.h>
>  #include <linux/tcp.h>
>  #include <linux/init.h>
> +#include <linux/spinlock.h>
>  #include <linux/dma-mapping.h>

Please ignore the patch. This #include should not be there.

I'll resend.

-- 
Ueimor
