From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] defxx.c: dfx_bus_init() is __devexit not __devinit
Date: Tue, 23 Oct 2007 20:23:35 -0400
Message-ID: <471E9087.7030309@pobox.com>
References: <Pine.LNX.4.64N.0710221809350.988@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36027 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755577AbXJXAXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 20:23:43 -0400
In-Reply-To: <Pine.LNX.4.64N.0710221809350.988@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
>  The dfx_bus_uninit() call is called from dfx_unregister() which is 
> __devexit and which is ultimately the ->remove call for the device.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
>  It should be obvious.  Please apply.
> 
>   Maciej
> 
> patch-mips-2.6.23-rc5-20070904-defxx-devexit-0
> diff -up --recursive --new-file linux-mips-2.6.23-rc5-20070904.macro/drivers/net/defxx.c linux-mips-2.6.23-rc5-20070904/drivers/net/defxx.c
> --- linux-mips-2.6.23-rc5-20070904.macro/drivers/net/defxx.c	2007-09-04 04:55:41.000000000 +0000
> +++ linux-mips-2.6.23-rc5-20070904/drivers/net/defxx.c	2007-10-12 00:21:35.000000000 +0000
> @@ -806,7 +806,7 @@ static void __devinit dfx_bus_init(struc
>   *   Interrupts are disabled at the adapter bus-specific logic.
>   */
>  
> -static void __devinit dfx_bus_uninit(struct net_device *dev)
> +static void __devexit dfx_bus_uninit(struct net_device *dev)
>  {
>  	DFX_board_t *bp = netdev_priv(dev);

applied


