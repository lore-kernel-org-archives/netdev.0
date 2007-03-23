From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Fix return code in pci-skeleton.c
Date: Fri, 23 Mar 2007 01:49:54 -0400
Message-ID: <46036A82.1080600@garzik.org>
References: <20070316220021.GA11929@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60443 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753166AbXCWFt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 01:49:56 -0400
In-Reply-To: <20070316220021.GA11929@kryten>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Blanchard wrote:
> We assign the return value of register_netdev to i, but return rc later
> on. Fix it.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
> 
> diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
> index 00ca0fd..6ca4e4f 100644
> --- a/drivers/net/pci-skeleton.c
> +++ b/drivers/net/pci-skeleton.c
> @@ -710,8 +710,8 @@ match:
>  		tp->chipset,
>  		rtl_chip_info[tp->chipset].name);
>  
> -	i = register_netdev (dev);
> -	if (i)
> +	rc = register_netdev (dev);
> +	if (rc)
>  		goto err_out_unmap;

applied


