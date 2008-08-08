From: Jonathan Cameron <jic23@cam.ac.uk>
Subject: Re: [PATCH 2.6.27-rc1] smc91x.c smc_drv_remove bug
Date: Fri, 08 Aug 2008 13:25:03 +0100
Message-ID: <489C3B1F.9010808@cam.ac.uk>
References: <4892123C.2060007@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppsw-7.csi.cam.ac.uk ([131.111.8.137]:41784 "EHLO
	ppsw-7.csi.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbYHHMZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 08:25:06 -0400
In-Reply-To: <4892123C.2060007@cam.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All,

Guessing Nicolas is away at the mo (or this one passed him by).
Would be good to get this trivial bug fix sorted out.

Thanks,

--
Jonathan Cameron
> From: Jonathan Cameron
> 
> Trivial bug fix for typo in smc91x.c that results in null pointer dereference
> 
> Signed-of-by: Jonathan Cameron
> 
> --
> Could just have submitted this as a bug report, but as it's a trivial patch
> this seemed easier. Clearly this will be irrelevant if people have moved board
> configs to using resource names, but for now... Not been involved with net drivers
> before so sorry if I've sent it to the wrong people!
> 
> /drivers/net/smc91x.c	2008-07-31 12:02:47.000000000 +0100
> +++ b/drivers/net/smc91x.c	2008-07-31 20:06:19.000000000 +0100
> @@ -2255,7 +2255,7 @@ static int smc_drv_remove(struct platfor
>  
>  	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-regs");
>  	if (!res)
> -		platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	release_mem_region(res->start, SMC_IO_EXTENT);
>  
>  	free_netdev(ndev);
> 
> 

