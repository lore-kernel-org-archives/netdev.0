From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] net: added support for 40GbE link.
Date: Mon, 18 Jun 2012 09:27:39 -0700
Message-ID: <4FDF56FB.9080509@hp.com>
References: <0c7c97b0-bfe1-4143-a562-2019f86912fc@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: Parav Pandit <parav.pandit@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:37314 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510Ab2FRQ1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 12:27:40 -0400
In-Reply-To: <0c7c97b0-bfe1-4143-a562-2019f86912fc@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2012 05:44 AM, Parav Pandit wrote:

> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 297370a..1ebfa6e 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -1153,6 +1153,10 @@ struct ethtool_ops {
>   #define SUPPORTED_10000baseR_FEC	(1<<  20)
>   #define SUPPORTED_20000baseMLD2_Full	(1<<  21)
>   #define SUPPORTED_20000baseKR2_Full	(1<<  22)
> +#define SUPPORTED_40000baseKR4_Full	(1<<  23)
> +#define SUPPORTED_40000baseCR4_Full	(1<<  24)
> +#define SUPPORTED_40000baseSR4_Full	(1<<  25)
> +#define SUPPORTED_40000baseLR4_Full	(1<<  26)
>
>   /* Indicates what features are advertised by the interface. */
>   #define ADVERTISED_10baseT_Half		(1<<  0)
> @@ -1178,6 +1182,10 @@ struct ethtool_ops {
>   #define ADVERTISED_10000baseR_FEC	(1<<  20)
>   #define ADVERTISED_20000baseMLD2_Full	(1<<  21)
>   #define ADVERTISED_20000baseKR2_Full	(1<<  22)
> +#define ADVERTISED_40000baseKR4_Full	(1<<  23)
> +#define ADVERTISED_40000baseCR4_Full	(1<<  24)
> +#define ADVERTISED_40000baseSR4_Full	(1<<  25)
> +#define ADVERTISED_40000baseLR4_Full	(1<<  26)

Any idea how many defines will be wanted for 100 Gbit Ethernet? 
Supported and advertising in ethtool_cmd are __u32s...

rick jones
