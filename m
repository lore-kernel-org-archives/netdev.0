From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] tulip, kernel 2.4.26-rc2, 2nd try
Date: Fri, 9 Apr 2004 21:58:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409215817.A22121@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.44.0404021455140.4496-100000@seahawk> <Pine.LNX.4.43.0404091519200.19041-100000@skyhawk.ecc.engr.uky.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tulip-devel@lists.sourceforge.net, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Timothy I Mattox <tmattox@engr.uky.edu>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.43.0404091519200.19041-100000@skyhawk.ecc.engr.uky.edu>; from tmattox@engr.uky.edu on Fri, Apr 09, 2004 at 03:30:34PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Timothy I Mattox <tmattox@engr.uky.edu> :
[...]
> diff -Naur -p linux-2.4.26-rc2/drivers/net/tulip/timer.c linux-2.4.26-rc2-comet/drivers/net/tulip/timer.c
> --- linux-2.4.26-rc2/drivers/net/tulip/timer.c	Fri Jun 13 10:51:35 2003
> +++ linux-2.4.26-rc2-comet/drivers/net/tulip/timer.c	Fri Apr  9 15:08:44 2004
[...]
> +	if (tulip_check_duplex(dev) < 0)
> +		{ /* netif_carrier_off(dev); */ }
> +	else
> +		{ /* netif_carrier_on(dev); */ }
>  	mod_timer(&tp->timer, RUN_AT(next_tick));

?

--
Ueimor
