From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH linux-2.6.35-rc3] micrel phy driver
Date: Mon, 28 Jun 2010 20:23:47 +0100
Message-ID: <1277753027.2089.22.camel@achroite.uk.solarflarecom.com>
References: <C43529A246480145B0A6D0234BDB0F0D0212A2@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Choi, David" <David.Choi@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59298 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab0F1TXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 15:23:51 -0400
In-Reply-To: <C43529A246480145B0A6D0234BDB0F0D0212A2@MELANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-28 at 11:51 -0700, Choi, David wrote:
[...]
> @@ -106,8 +233,12 @@ MODULE_LICENSE("GPL");
>  
>  static struct mdio_device_id micrel_tbl[] = {
>  	{ PHY_ID_KSZ9021, 0x000fff10 },
> -	{ PHY_ID_VSC8201, 0x00fffff0 },
>  	{ PHY_ID_KS8001, 0x00fffff0 },
> +	{ PHY_ID_KSZ9021, 0x000fff10 },
> +	{ PHY_ID_KS8001, 0x00fffff0 },
> +	{ PHY_ID_KS8737, 0x00fffff0 },
> +	{ PHY_ID_KS8041, 0x00fffff0 },
> +	{ PHY_ID_KS8051, 0x00fffff0 },
>  	{ }
>  };

You're duplicating the device IDs for KSZ9021 and KS8001.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

