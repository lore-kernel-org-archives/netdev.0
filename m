From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH] fec: use linux/*.h instead of asm/*.h
Date: Thu, 15 Jan 2009 13:55:12 +1000
Message-ID: <496EB3A0.5060201@snapgear.com>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-2-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-3-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-4-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sebastian Siewior <bigeasy@linutronix.de>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:46615 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752759AbZAODzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 22:55:14 -0500
In-Reply-To: <1231949353-29630-4-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sacha,

Sascha Hauer wrote:
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> ---

No problems with this either for ColdFire,

Acked-by:  Greg Ungerer <gerg@uclinux.org>



>  drivers/net/fec.c |    8 +++-----
>  1 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 812d8be..1a07d56 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -36,15 +36,13 @@
>  #include <linux/spinlock.h>
>  #include <linux/workqueue.h>
>  #include <linux/bitops.h>
> +#include <linux/io.h>
> +#include <linux/irq.h>
>  
> -#include <asm/irq.h>
> -#include <asm/uaccess.h>
> -#include <asm/io.h>
> -#include <asm/pgtable.h>
>  #include <asm/cacheflush.h>
> -
>  #include <asm/coldfire.h>
>  #include <asm/mcfsim.h>
> +
>  #include "fec.h"
>  
>  #if defined(CONFIG_FEC2)

-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear, a McAfee Company                  PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
