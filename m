From: Martin Diehl <lists-d9SKjHWnQKCzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] Drop ISA dependencies from IRDA drivers
Date: Fri, 16 Jul 2004 00:57:59 +0200 (CEST)
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Message-ID: <Pine.LNX.4.44.0407160055360.14037-100000@notebook.home.mdiehl.de>
References: <20040715224235.GA5164@bougret.hpl.hp.com>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak-h9bWGtP8wOw@public.gmane.org>, Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
   <netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org>, <irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
   Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>, <the_nihilant-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>,
   Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Jean Tourrilhes <jt-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
In-Reply-To: <20040715224235.GA5164-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5ji9XKYC2TYK4Io4DoRGLOrNAH6kLmebB@public.gmane.org>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5lLLH9aP38KF1pqr+6INuaA@public.gmane.org>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5R9m/fhtKvoLKtGCp0j7rLg@public.gmane.org>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

On Thu, 15 Jul 2004, Jean Tourrilhes wrote:

> 	irda_setup_dma was (supposedly) fixed in 2.6.8-rc1, and no
> longer depend on CONFIG_ISA. Those driver are supposed to work on 64
> bits.

Ok, so maybe the following is missing in addition to Andi's patch?

Martin

-----------

--- linux-2.6.8-rc1/net/irda/irda_device.c	Tue Jul 13 00:31:34 2004
+++ v2.6.8-rc1-md/net/irda/irda_device.c	Fri Jul 16 00:45:08 2004
@@ -529,7 +529,6 @@ int irda_device_set_mode(struct net_devi
 	return ret;
 }
 
-#ifdef CONFIG_ISA
 /*
  * Function setup_dma (idev, buffer, count, mode)
  *
@@ -552,4 +551,3 @@ void irda_setup_dma(int channel, dma_add
 	release_dma_lock(flags);
 }
 EXPORT_SYMBOL(irda_setup_dma);
-#endif



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
