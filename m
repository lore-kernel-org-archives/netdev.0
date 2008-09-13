From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] smc911x: remove duplicate debug printout
Date: Sat, 13 Sep 2008 15:30:15 -0400
Message-ID: <48CC14C7.7000601@garzik.org>
References: <20080908050316.11556.70782.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@redhat.com,
	akpm@linux-foundation.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50144 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752870AbYIMTaT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:30:19 -0400
In-Reply-To: <20080908050316.11556.70782.sendpatchset@rx1.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Magnus Damm wrote:
> From: Magnus Damm <damm@igel.co.jp>
> 
> Remove duplicated debug printout.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> ---
> 
>  drivers/net/smc911x.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> --- 0001/drivers/net/smc911x.c
> +++ work/drivers/net/smc911x.c	2008-08-29 11:54:00.000000000 +0900
> @@ -1174,8 +1174,6 @@ static irqreturn_t smc911x_interrupt(int
>  
>  	spin_unlock_irqrestore(&lp->lock, flags);
>  
> -	DBG(3, "%s: Interrupt done (%d loops)\n", dev->name, 8-timeout);
> -
>  	return IRQ_HANDLED;

applied

