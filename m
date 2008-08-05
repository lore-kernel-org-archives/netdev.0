From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [2.6 patch] drivers/net/: remove CVS keywords
Date: Tue, 5 Aug 2008 23:44:52 +0300
Message-ID: <20080805204452.GL22895@cs181140183.pp.htv.fi>
References: <20080519220619.GL17716@cs181133002.pp.htv.fi> <48354660.7060500@pobox.com> <20080603181408.GC2663@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:56087 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754995AbYHEUqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 16:46:16 -0400
Content-Disposition: inline
In-Reply-To: <20080603181408.GC2663@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping ?


On Tue, Jun 03, 2008 at 09:14:08PM +0300, Adrian Bunk wrote:
> On Thu, May 22, 2008 at 06:09:36AM -0400, Jeff Garzik wrote:
> > Adrian Bunk wrote:
> >> This patch removes some CVS keywords that weren't updated for a long  
> >> time.
> >>
> >> I haven't touched drivers that looked as if they might still be used.
> >>
> >> In three drivers I've also removed printk's printing them since they  
> >> were part of several printk's in a row and it doesn't make sense to  
> >> print ancient version information to the user.
> >>
> >> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> >
> > I'm fine with removing CVS keywords, but I do not agree with removing  
> > net driver version numbers that have been in the drivers for a while.
> 
> Below is the part of the patches that removes these printk's.
> 
> Do CVS $Revision tags that haven't been updated for ages really qualify 
> as net driver version numbers?
> 
> I can resend the patch with these changes removed, I'm just asking 
> whether you might confuse this with regular version numbers.
> 
> > 	Jeff
> 
> cu
> Adrian
> 
> --- a/drivers/net/82596.c
> +++ b/drivers/net/82596.c
> @@ -59,9 +59,6 @@
>  #include <asm/pgtable.h>
>  #include <asm/cacheflush.h>
>  
> -static char version[] __initdata =
> -	"82596.c $Revision: 1.5 $\n";
> -
>  #define DRV_NAME	"82596"
>  
>  /* DEBUG flags
> @@ -1227,8 +1224,6 @@ struct net_device * __init i82596_probe(int unit)
>  
>  	DEB(DEB_PROBE,printk(" IRQ %d.\n", dev->irq));
>  
> -	DEB(DEB_PROBE,printk(KERN_INFO "%s", version));
> -
>  	/* The 82596-specific entries in the device structure. */
>  	dev->open = i596_open;
>  	dev->stop = i596_close;
> --- a/drivers/net/de600.c
> +++ b/drivers/net/de600.c
> @@ -1,4 +1,3 @@
> -static const char version[] = "de600.c: $Revision: 1.41-2.5 $,  Bjorn Ekwall (bj0rn@blox.se)\n";
>  /*
>   *	de600.c
>   *
> @@ -398,9 +397,6 @@ static struct net_device * __init de600_probe(void)
>  	}
>  
>  	printk(KERN_INFO "%s: D-Link DE-600 pocket adapter", dev->name);
> -	/* Alpha testers must have the version number to report bugs. */
> -	if (de600_debug > 1)
> -		printk(version);
>  
>  	/* probe for adapter */
>  	err = -ENODEV;
> --- a/drivers/net/de620.c
> +++ b/drivers/net/de620.c
> @@ -38,8 +35,6 @@
>   *	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
>   *
>   *****************************************************************************/
> -static const char version[] =
> -	"de620.c: $Revision: 1.40 $,  Bjorn Ekwall <bj0rn@blox.se>\n";
>  
>  /***********************************************************************
>   *
> @@ -828,9 +823,6 @@ struct net_device * __init de620_probe(int unit)
>  		netdev_boot_setup_check(dev);
>  	}
>  
> -	if (de620_debug)
> -		printk(version);
> -
>  	printk(KERN_INFO "D-Link DE-620 pocket adapter");
>  
>  	if (!request_region(dev->base_addr, 3, "de620")) {
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

