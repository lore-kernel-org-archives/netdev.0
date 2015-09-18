From: Luis de Bethencourt <luis@debethencourt.com>
Subject: Re: [PATCH] net: gianfar_ptp: Fix module autoload for OF platform
 driver
Date: Fri, 18 Sep 2015 21:54:18 +0200
Message-ID: <20150918195418.GA3482@goodgumbo.baconseed.org>
References: <20150918195244.GA3221@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33227 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109AbbIRTyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 15:54:20 -0400
Content-Disposition: inline
In-Reply-To: <20150918195244.GA3221@goodgumbo.baconseed.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ignore this. It has the wrong [PATCH] tag.

Apologies,
Luis

On Fri, Sep 18, 2015 at 09:52:44PM +0200, Luis de Bethencourt wrote:
> This platform driver has a OF device ID table but the OF module
> alias information is not created so module autoloading won't work.
> 
> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
> ---
> 
> Corrected the subject line as requested by Richard.
> https://lkml.org/lkml/2015/9/18/717
> 
> Thanks for the review,
> Luis
> 
>  drivers/net/ethernet/freescale/gianfar_ptp.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
> index 8e3cd77..664d0c2 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ptp.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
> @@ -557,6 +557,7 @@ static const struct of_device_id match_table[] = {
>  	{ .compatible = "fsl,etsec-ptp" },
>  	{},
>  };
> +MODULE_DEVICE_TABLE(of, match_table);
>  
>  static struct platform_driver gianfar_ptp_driver = {
>  	.driver = {
> -- 
> 2.4.6
> 
