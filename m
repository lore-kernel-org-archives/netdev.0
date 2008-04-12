From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sky2: missing chip name for Yukon Supreme
Date: Sat, 12 Apr 2008 01:53:44 -0400
Message-ID: <48004E68.5070209@garzik.org>
References: <20080410150614.7da71ff8@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44459 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753267AbYDLFxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 01:53:46 -0400
In-Reply-To: <20080410150614.7da71ff8@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Any usage of sky2 on new Yukon Supreme would cause a NULL dereference.
> The chip is very new, so the support is still untested; vendor has
> not sent any eval hardware.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> ---
> Please apply for 2.6.25
> 
> --- a/drivers/net/sky2.c	2008-04-10 14:01:05.000000000 -0500
> +++ b/drivers/net/sky2.c	2008-04-10 14:04:23.000000000 -0500
> @@ -154,6 +154,7 @@ static const char *yukon2_name[] = {
>  	"EC",		/* 0xb6 */
>  	"FE",		/* 0xb7 */
>  	"FE+",		/* 0xb8 */
> +	"Supreme",	/* 0xb9 */
>  };
>  
>  static void sky2_set_multicast(struct net_device *dev);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in

applied


