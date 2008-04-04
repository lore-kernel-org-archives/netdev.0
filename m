From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sc92031: sysfs link missing
Date: Fri, 04 Apr 2008 01:46:05 -0400
Message-ID: <47F5C09D.5000200@pobox.com>
References: <bug-10380-10286@http.bugzilla.kernel.org/>	<20080402091435.39f99428.akpm@linux-foundation.org> <20080402093956.2520ebfd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Cesar Eduardo Barros <cesarb@cesarb.net>, tom@sharkbay.at
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59874 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754410AbYDDFqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 01:46:15 -0400
In-Reply-To: <20080402093956.2520ebfd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Add missing sysfs device association. Compile tested only -ENOHW.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/drivers/net/sc92031.c	2008-04-02 09:34:35.000000000 -0700
> +++ b/drivers/net/sc92031.c	2008-04-02 09:36:53.000000000 -0700
> @@ -1446,6 +1446,7 @@ static int __devinit sc92031_probe(struc
>  	}
>  
>  	pci_set_drvdata(pdev, dev);
> +	SET_NETDEV_DEV(dev, &hw->pdev->dev);
>  
>  #if SC92031_USE_BAR == 0
>  	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);

applied


