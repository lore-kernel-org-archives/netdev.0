From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: Re: [patch 2.6.24-git] net/enc28j60: section fix
Date: Thu, 07 Feb 2008 12:13:17 +0100
Message-ID: <47AAE7CD.9050801@eptar.com>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <47A9EA42.3080800@eptar.com> <200802062208.48838.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay03.albacom.net ([217.220.57.137]:44296 "EHLO
	fe-relay03.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272AbYBGLMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 06:12:14 -0500
In-Reply-To: <200802062208.48838.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> Minor bugfixes to the enc28j60 driver ... wrong section marking and
> indentation, and bogus use of spi_bus_type.  (Setting the bus type
> of a driver is a SPI framework responsibility.)
>
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
>   

Acked-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>
> ---
> Bonus patch.
>
>  drivers/net/enc28j60.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
>
> --- a/drivers/net/enc28j60.c
> +++ b/drivers/net/enc28j60.c
> @@ -1555,7 +1555,7 @@ error_alloc:
>  	return ret;
>  }
>  
> -static int enc28j60_remove(struct spi_device *spi)
> +static int __devexit enc28j60_remove(struct spi_device *spi)
>  {
>  	struct enc28j60_net *priv = dev_get_drvdata(&spi->dev);
>  
> @@ -1572,9 +1572,8 @@ static int enc28j60_remove(struct spi_de
>  static struct spi_driver enc28j60_driver = {
>  	.driver = {
>  		   .name = DRV_NAME,
> -		   .bus = &spi_bus_type,
>  		   .owner = THIS_MODULE,
> -		   },
> +	 },
>  	.probe = enc28j60_probe,
>  	.remove = __devexit_p(enc28j60_remove),
>  };
>
>
>   

