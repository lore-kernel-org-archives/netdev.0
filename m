From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] myri10ge: improve port type reporting in ethtool output
Date: Mon, 19 Oct 2009 09:12:09 +0100
Message-ID: <1255939929.3916.13.camel@localhost>
References: <4ADBFA88.8030300@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:45157 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572AbZJSIML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 04:12:11 -0400
In-Reply-To: <4ADBFA88.8030300@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-10-19 at 07:35 +0200, Brice Goglin wrote:
> Improve the reporting of the port type in ethtool,
> update for new boards.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> 
> --- a/drivers/net/myri10ge/myri10ge.c
> +++ b/drivers/net/myri10ge/myri10ge.c
> @@ -75,7 +75,7 @@
>  #include "myri10ge_mcp.h"
>  #include "myri10ge_mcp_gen_header.h"
>  
> -#define MYRI10GE_VERSION_STR "1.5.0-1.432"
> +#define MYRI10GE_VERSION_STR "1.5.1-1.450"
>  
>  MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
>  MODULE_AUTHOR("Maintainer: help@myri.com");
> @@ -1601,6 +1601,8 @@ myri10ge_get_settings(struct net_device *netdev,
> struct ethtool_cmd *cmd)
>      cmd->autoneg = AUTONEG_DISABLE;
>      cmd->speed = SPEED_10000;
>      cmd->duplex = DUPLEX_FULL;
> +    cmd->supported = SUPPORTED_10000baseT_Full;
> +    cmd->advertising = ADVERTISED_10000baseT_Full;
[...]

Lying about link modes is not an improvement.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

