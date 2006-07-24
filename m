From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] skge: chip clock rate typo
Date: Mon, 24 Jul 2006 16:34:46 -0500
Message-ID: <44C53CF6.7040400@lwfinger.net>
References: <200607222330.30842.mb@bu3sch.de> <20060719133535.40e490fc@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:39570 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751450AbWGXVen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 17:34:43 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060719133535.40e490fc@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Michael Buesch spotted this typo.  The impact is that the incorrect value
> was being computed for blinking LED and interrupt moderation values.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> --- skge-2.6.orig/drivers/net/skge.c
> +++ skge-2.6/drivers/net/skge.c
> @@ -519,7 +519,7 @@ static inline u32 hwkhz(const struct skg
>  	if (hw->chip_id == CHIP_ID_GENESIS)
>  		return 53215; /* or:  53.125 MHz */
-------------------------^   Should this be 53125?

Larry

