From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] SMC91x: delete unused local variable "lp"
Date: Fri, 31 Oct 2008 00:48:53 -0400
Message-ID: <490A8E35.8080204@garzik.org>
References: <1225288566-18457-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54185 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864AbYJaEs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:48:59 -0400
In-Reply-To: <1225288566-18457-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Frysinger wrote:
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  drivers/net/smc91x.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index c70870e..6f9895d 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -2060,7 +2060,6 @@ static int smc_request_attrib(struct platform_device *pdev,
>  			      struct net_device *ndev)
>  {
>  	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
> -	struct smc_local *lp = netdev_priv(ndev);
>  
>  	if (!res)
>  		return 0;
> @@ -2075,7 +2074,6 @@ static void smc_release_attrib(struct platform_device *pdev,
>  			       struct net_device *ndev)
>  {
>  	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
> -	struct smc_local *lp = netdev_priv(ndev);
>  

applied


