From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 5/5] of_mdio: get_phy_device() doesn't return NULL anymore
Date: Sun, 24 Apr 2016 20:37:31 +0300
Message-ID: <571D045B.3020702@cogentembedded.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
 <2718908.IUaySUkXrd@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, Rob Herring <robh+dt@kernel.org>,
	Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33231 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbcDXRhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 13:37:35 -0400
Received: by mail-lf0-f47.google.com with SMTP id y84so8141088lfc.0
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 10:37:34 -0700 (PDT)
In-Reply-To: <2718908.IUaySUkXrd@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2016 08:31 PM, Sergei Shtylyov wrote:

> Now that get_phy_device() no longer returns NULL on error, we don't need
> to check for it...
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>

    Oops, forgot to CC: the DT people, doing that now...

> ---
>   drivers/of/of_mdio.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: net-next/drivers/of/of_mdio.c
> ===================================================================
> --- net-next.orig/drivers/of/of_mdio.c
> +++ net-next/drivers/of/of_mdio.c
> @@ -56,7 +56,7 @@ static void of_mdiobus_register_phy(stru
>   		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
>   	else
>   		phy = get_phy_device(mdio, addr, is_c45);
> -	if (IS_ERR_OR_NULL(phy))
> +	if (IS_ERR(phy))
>   		return;
>
>   	rc = irq_of_parse_and_map(child, 0);
