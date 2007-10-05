From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 16:30:34 -0700 (PDT)
Message-ID: <20071005.163034.26284928.davem@davemloft.net>
References: <20071005083924.4e7f5d59@freepuppy.rosehill>
	<20071005.141247.71101713.davem@davemloft.net>
	<20071005141850.0fdd0858@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50212
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753634AbXJEXae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 19:30:34 -0400
In-Reply-To: <20071005141850.0fdd0858@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 14:18:50 -0700

> --- a/drivers/net/niu.c	2007-10-05 08:09:31.000000000 -0700
> +++ b/drivers/net/niu.c	2007-10-05 08:42:06.000000000 -0700
> @@ -804,7 +804,7 @@ static int bcm8704_init_user_dev3(struct
>  	if (err)
>  		return err;
>  
> -	udelay(1000000);
> +	mdelay(1000);
>  
>  	return 0;
>  }
> 

Applied, thanks Stephen.
