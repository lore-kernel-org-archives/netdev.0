From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.25? 3/3] sc92031: sysfs link missing
Date: Sat, 12 Apr 2008 04:43:01 -0400
Message-ID: <48007615.2070909@garzik.org>
References: <200804110430.m3B4UcVU000439@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	shemminger@vyatta.com, cesarb@cesarb.net, jgarzik@pobox.com,
	tom@sharkbay.at
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41708 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756789AbYDLInE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 04:43:04 -0400
In-Reply-To: <200804110430.m3B4UcVU000439@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> 
> Add missing sysfs device association. Compile tested only -ENOHW.
> 
> Addresses http://bugzilla.kernel.org/show_bug.cgi?id=10380
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Cc: Cesar Eduardo Barros <cesarb@cesarb.net>
> Cc: <tom@sharkbay.at>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/sc92031.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff -puN drivers/net/sc92031.c~sc92031-sysfs-link-missing drivers/net/sc92031.c
> --- a/drivers/net/sc92031.c~sc92031-sysfs-link-missing
> +++ a/drivers/net/sc92031.c
> @@ -1444,6 +1444,7 @@ static int __devinit sc92031_probe(struc
>  	}
>  
>  	pci_set_drvdata(pdev, dev);
> +	SET_NETDEV_DEV(dev, &pdev->dev);
>  
>  #if SC92031_USE_BAR == 0
>  	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);

applied

