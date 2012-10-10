From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH 3.6.0- 2/3] net/mdio-octeon: use module_platform_driver
 macro
Date: Wed, 10 Oct 2012 11:46:14 -0700
Message-ID: <5075C276.2040103@gmail.com>
References: <1349893751-6867-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bordug@ru.mvista.com, netdev@vger.kernel.org,
	david.daney@cavium.com, linville@tuxdriver.com, kaloz@openwrt.org
To: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41918 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755372Ab2JJSqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 14:46:16 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so1014272pbb.19
        for <netdev@vger.kernel.org>; Wed, 10 Oct 2012 11:46:16 -0700 (PDT)
In-Reply-To: <1349893751-6867-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2012 11:29 AM, Srinivas KANDAGATLA wrote:
> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>
> This patch removes some code duplication by using
> module_platform_driver.
>
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Acked-by: David Daney <david.daney@cavium.com>

I have the same thing locally, but you beat me to sending it in.


> ---
>   drivers/net/phy/mdio-octeon.c |   14 +-------------
>   1 files changed, 1 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
> index d4015aa..84f7c47 100644
> --- a/drivers/net/phy/mdio-octeon.c
> +++ b/drivers/net/phy/mdio-octeon.c
> @@ -196,19 +196,7 @@ void octeon_mdiobus_force_mod_depencency(void)
>   	/* Let ethernet drivers force us to be loaded.  */
>   }
>   EXPORT_SYMBOL(octeon_mdiobus_force_mod_depencency);
> -
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
