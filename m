From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH 5/5] net: mdio-octeon: Use module_platform_driver()
Date: Wed, 20 Mar 2013 09:12:38 -0700
Message-ID: <5149DFF6.1010304@gmail.com>
References: <1363779692-4395-1-git-send-email-sachin.kamat@linaro.org> <1363779692-4395-5-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	David Daney <ddaney@caviumnetworks.com>
To: Sachin Kamat <sachin.kamat@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:58240 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab3CTQMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:12:46 -0400
Received: by mail-pb0-f43.google.com with SMTP id md12so1491664pbc.16
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 09:12:45 -0700 (PDT)
In-Reply-To: <1363779692-4395-5-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2013 04:41 AM, Sachin Kamat wrote:
> module_platform_driver macro removes some boilerplate and
> simplifies the code.
>
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> Cc: David Daney <ddaney@caviumnetworks.com>

I was going to send the equivalent patch.

Acked-by: David Daney <ddaney@caviumnetworks.com>


> ---
>   drivers/net/phy/mdio-octeon.c |   13 +------------
>   1 files changed, 1 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
> index 09297fe..c2c878d 100644
> --- a/drivers/net/phy/mdio-octeon.c
> +++ b/drivers/net/phy/mdio-octeon.c
> @@ -197,18 +197,7 @@ void octeon_mdiobus_force_mod_depencency(void)
>   }
>   EXPORT_SYMBOL(octeon_mdiobus_force_mod_depencency);
>
> -static int __init octeon_mdiobus_mod_init(void)
> -{
> -	return platform_driver_register(&octeon_mdiobus_driver);
> -}
> -
> -static void __exit octeon_mdiobus_mod_exit(void)
> -{
> -	platform_driver_unregister(&octeon_mdiobus_driver);
> -}
> -
> -module_init(octeon_mdiobus_mod_init);
> -module_exit(octeon_mdiobus_mod_exit);
> +module_platform_driver(octeon_mdiobus_driver);
>
>   MODULE_DESCRIPTION(DRV_DESCRIPTION);
>   MODULE_VERSION(DRV_VERSION);
>
