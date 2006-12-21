From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6.20-rc1 05/10] if_fddi.h: Add a missing inclusion
Date: Wed, 20 Dec 2006 20:55:55 -0800
Message-ID: <20061220205555.9a48c327.akpm@osdl.org>
References: <Pine.LNX.4.64N.0612201113410.11005@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:37971 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422695AbWLUE4F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 23:56:05 -0500
To: "Maciej W. Rozycki" <macro@linux-mips.org>
In-Reply-To: <Pine.LNX.4.64N.0612201113410.11005@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Dec 2006 12:01:55 +0000 (GMT)
"Maciej W. Rozycki" <macro@linux-mips.org> wrote:

>  This is a change to include <linux/netdevice.h> in <linux/if_fddi.h> 
> which is needed for "struct fddi_statistics".
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
> 
>  Please apply.
> 
>   Maciej
> 
> patch-mips-2.6.18-20060920-if_fddi-netdev-0
> diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/include/linux/if_fddi.h linux-mips-2.6.18-20060920/include/linux/if_fddi.h
> --- linux-mips-2.6.18-20060920.macro/include/linux/if_fddi.h	2006-09-20 20:51:20.000000000 +0000
> +++ linux-mips-2.6.18-20060920/include/linux/if_fddi.h	2006-12-14 04:36:58.000000000 +0000
> @@ -103,6 +103,8 @@ struct fddihdr
>  	} __attribute__ ((packed));
>  
>  #ifdef __KERNEL__
> +#include <linux/netdevice.h>
> +
>  /* Define FDDI statistics structure */
>  struct fddi_statistics {
>  

I'll treat this a a bugfix, unrelated to the turbochannel changes.

Which may be wrong, but I doubt it.
