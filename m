From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 79821] New: ethernet/freescale/gianfar_ethtool.c:1584:
 possible bad expression ?
Date: Thu, 10 Jul 2014 17:07:04 -0700 (PDT)
Message-ID: <20140710.170704.1439211670228191396.davem@davemloft.net>
References: <20140710055100.394e6a09@samsung-9>
	<20140710.170610.787241466056112359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sebastian.poehn@belden.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbaGKAHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 20:07:04 -0400
In-Reply-To: <20140710.170610.787241466056112359.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 10 Jul 2014 17:06:10 -0700 (PDT)

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 10 Jul 2014 05:51:00 -0700
> 
>> [linux-3.16-rc4/drivers/net/ethernet/freescale/gianfar_ethtool.c:1584]: (style)
>> Same expression on both sides of '|'.
>> 
>>     for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);
> 
> Probably this is meant to be:
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> index 76d7070..f697118 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> @@ -1581,7 +1581,7 @@ static int gfar_write_filer_table(struct gfar_private *priv,
>  		return -EBUSY;
>  
>  	/* Fill regular entries */
> -	for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);
> +	for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].prop);
>  	     i++)
>  		gfar_write_filer(priv, i, tab->fe[i].ctrl, tab->fe[i].prop);
>  	/* Fill the rest with fall-troughs */
> 
> But only a Gianfar expert can say for sure.
> 
> Sebastian, this is your code, please help us out.

Ok, we have a problem, Sebastian's email bounces.

Anyone else who knows this chip can help us out?  We don't have a listed
maintainer for Gianfar in MAINTAINERS :-/
