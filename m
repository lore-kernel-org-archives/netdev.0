From: Martin Diehl <lists-d9SKjHWnQKCzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] Drop ISA dependencies from IRDA drivers
Date: Fri, 16 Jul 2004 00:32:44 +0200 (CEST)
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Message-ID: <Pine.LNX.4.44.0407160027410.14037-100000@notebook.home.mdiehl.de>
References: <20040715215552.GA46635@muc.de>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, <netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org>,
   <irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
   <the_nihilant-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>, Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Andi Kleen <ak-h9bWGtP8wOw@public.gmane.org>
In-Reply-To: <20040715215552.GA46635-h9bWGtP8wOw@public.gmane.org>
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5ji9XKYC2TYK4Io4DoRGLOrNAH6kLmebB@public.gmane.org>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5lLLH9aP38KF1pqr+6INuaA@public.gmane.org>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5R9m/fhtKvoLKtGCp0j7rLg@public.gmane.org>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

On 15 Jul 2004, Andi Kleen wrote:

> Remove wrong ISA dependencies for IRDA drivers.
> 
> 
> diff -u linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig-o linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig
> --- linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig-o	2004-07-12 06:09:05.000000000 +0200
> +++ linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig	2004-07-15 18:33:48.000000000 +0200
> @@ -310,7 +310,7 @@
>  
>  config NSC_FIR
>  	tristate "NSC PC87108/PC87338"
> -	depends on IRDA && ISA
> +	depends on IRDA


Admittedly I haven't tried either, but I'm pretty sure this patch will 
break building those drivers because they are calling irda_setup_dma - 
which is CONFIG_ISA. Maybe this can be dropped but I don't see what's 
wrong with !64BIT instead.

Martin



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
