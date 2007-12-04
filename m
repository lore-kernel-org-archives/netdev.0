From: Joe Perches <joe@perches.com>
Subject: Re: Pull request for 'ipg' branch
Date: Tue, 04 Dec 2007 14:14:55 -0800
Message-ID: <1196806495.10819.16.camel@localhost>
References: <20071204214551.GA6345@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Pekka Enberg <penberg@cs.helsinki.fi>,
	Sorbica Shieh <sorbica@icplus.com.tw>,
	Jesse Huang <jesse@icplus.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4869 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004AbXLDWSE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 17:18:04 -0500
In-Reply-To: <20071204214551.GA6345@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2007-12-04 at 22:45 +0100, Francois Romieu wrote:
> diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
> index dbd23bb..f736c35 100644
> --- a/drivers/net/ipg.c
> +++ b/drivers/net/ipg.c
> -MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver "
> -		   DrvVer);
> +MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver");
>  MODULE_LICENSE("GPL");

> -	if ((sp->LED_Mode & 0x01) == 1)
> +	if ((sp->led_mode & 0x01) == 1)

I think the use of hex and decimal constants is odd.
I think "if (sp->led_mode & 0x01)" is better.
 
> diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
> index d5d092c..cda5388 100644
> --- a/drivers/net/ipg.h
> +++ b/drivers/net/ipg.h

>  /* Assign IPG_APPEND_FCS_ON_TX > 0 for auto FCS append on TX. */
> -#define         IPG_APPEND_FCS_ON_TX         TRUE
> +#define         IPG_APPEND_FCS_ON_TX         1

Why not true and false?

> @@ -753,8 +732,7 @@ enum ipg_regs {
>   * Miscellaneous macros.
>   */
>  
> -/* Marco for printing debug statements.
> -#  define IPG_DDEBUG_MSG(args...) printk(KERN_DEBUG "IPG: " ## args) */
> +/* Marco for printing debug statements. */

Macros

cheers, Joe

