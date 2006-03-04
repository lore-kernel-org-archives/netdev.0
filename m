From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] schedule eepro100.c for removal
Date: Sat, 4 Mar 2006 12:04:55 +0100
Message-ID: <20060304110454.GI9295@stusta.de>
References: <20060214152226.GK10701@stusta.de> <4408FA6E.3040808@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751233AbWCDLE4@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4408FA6E.3040808@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 03, 2006 at 09:24:46PM -0500, Jeff Garzik wrote:
> Adrian Bunk wrote:
> >Signed-off-by: Adrian Bunk <bunk@stusta.de>
> >
> >---
> >
> >This patch was already sent on:
> >- 4 Feb 2006
> >
> > Documentation/feature-removal-schedule.txt |    6 ++++++
> > drivers/net/eepro100.c                     |    1 +
> > 2 files changed, 7 insertions(+)
> >
> >--- linux-2.6.15-mm4-full/Documentation/feature-removal-schedule.txt.old 
> >2006-01-18 08:38:57.000000000 +0100
> >+++ linux-2.6.15-mm4-full/Documentation/feature-removal-schedule.txt 
> >2006-01-18 08:39:59.000000000 +0100
> >@@ -164,0 +165,6 @@
> >+---------------------------
> >+
> >+What:   eepro100 network driver
> >+When:   August 2006
> >+Why:    replaced by the e100 driver
> >+Who:    Adrian Bunk <bunk@stusta.de>
> 
> ACK, provided you change the year to 2007
> 
> >--- linux-2.6.16-rc1-mm5-full/drivers/net/eepro100.c.old	2006-02-03 
> >23:37:55.000000000 +0100
> >+++ linux-2.6.16-rc1-mm5-full/drivers/net/eepro100.c	2006-02-03 
> >23:39:10.000000000 +0100
> >@@ -2391,6 +2391,7 @@ static int __init eepro100_init_module(v
> > #ifdef MODULE
> > 	printk(version);
> > #endif
> >+	printk(KERN_WARNING "eepro100 will be removed soon, please use the 
> >e100 driver\n");
> > 	return pci_module_init(&eepro100_driver);
> 
> NAK

Other people wanted this part of the patch...


It seems the feature-removal-schedule.txt part with a changed date is 
already part of git-netdev-all.patch in recent -mm kernels.

Do you still want me to resend it?


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
