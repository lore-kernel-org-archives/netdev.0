From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: fix build break with !CONFIG_OF
Date: Wed, 21 Dec 2011 22:34:55 +0100
Message-ID: <4EF250FF.7090302@atmel.com>
References: <1324416029-28198-1-git-send-email-olof@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Jamie Iles <jamie@jamieiles.com>,
	linux-arm-kernel@lists.infradead.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:16804 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab1LUVfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 16:35:11 -0500
In-Reply-To: <1324416029-28198-1-git-send-email-olof@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2011 10:20 PM, Olof Johansson :
> This fixes the build of the macb driver that was broken by the DT changes:
> 
> drivers/net/ethernet/cadence/macb.c:1503: error: implicit declaration of function 'of_match_ptr'
> drivers/net/ethernet/cadence/macb.c:1503: error: 'macb_dt_ids' undeclared here (not in a function)
> drivers/net/ethernet/cadence/macb.c:1503: error: initializer element is not constant
> drivers/net/ethernet/cadence/macb.c:1503: error: (near initialization for 'macb_driver.driver.of_match_table')
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Olof, thanks for this patch.

Best regards,

> ---
> 
> Nicolas, care to ack this so I can apply it on top of the macb DT branch in arm-soc?
> 
>  drivers/net/ethernet/cadence/macb.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index baf1a0d..f3d5c65 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -23,6 +23,7 @@
>  #include <linux/platform_data/macb.h>
>  #include <linux/platform_device.h>
>  #include <linux/phy.h>
> +#include <linux/of.h>
>  #include <linux/of_device.h>
>  #include <linux/of_net.h>
>  


-- 
Nicolas Ferre
