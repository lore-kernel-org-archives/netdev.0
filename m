From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 06/10] Net: ibm_newemac, remove SPIN_LOCK_UNLOCKED
Date: Fri, 14 Dec 2007 16:14:12 -0500
Message-ID: <4762F224.8050203@garzik.org>
References: <200712140002.lBE02vqD025526@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jirislaby@gmail.com, jgarzik@pobox.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55918 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755716AbXLNVOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 16:14:15 -0500
In-Reply-To: <200712140002.lBE02vqD025526@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Jiri Slaby <jirislaby@gmail.com>
> 
> SPIN_LOCK_UNLOCKED is deprecated, use DEFINE_SPINLOCK instead
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/ibm_newemac/debug.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/ibm_newemac/debug.c~net-ibm_newemac-remove-spin_lock_unlocked drivers/net/ibm_newemac/debug.c
> --- a/drivers/net/ibm_newemac/debug.c~net-ibm_newemac-remove-spin_lock_unlocked
> +++ a/drivers/net/ibm_newemac/debug.c
> @@ -21,7 +21,7 @@
>  
>  #include "core.h"
>  
> -static spinlock_t emac_dbg_lock = SPIN_LOCK_UNLOCKED;
> +static DEFINE_SPINLOCK(emac_dbg_lock);
>  

applied #upstream-fixes


