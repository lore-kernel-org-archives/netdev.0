From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool v4: add autoneg advertise feature
Date: Thu, 24 Aug 2006 02:26:50 -0400
Message-ID: <44ED46AA.60004@pobox.com>
References: <20060805054256.14081.74770.stgit@lunar.tarbal.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56294 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030333AbWHXG0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 02:26:53 -0400
To: Jeff@lime.pobox.com, Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <20060805054256.14081.74770.stgit@lunar.tarbal.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff@lime.pobox.com wrote:
> @@ -598,25 +608,7 @@ static void parse_cmdline(int argc, char
>  		}
>  	}
>  
> -	if (autoneg_wanted == AUTONEG_ENABLE){
> -		if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
> -			advertising_wanted = ADVERTISED_10baseT_Half;
> -		else if (speed_wanted == SPEED_10 &&
> -			 duplex_wanted == DUPLEX_FULL)
> -			advertising_wanted = ADVERTISED_10baseT_Full;
> -		else if (speed_wanted == SPEED_100 &&
> -			 duplex_wanted == DUPLEX_HALF)
> -			advertising_wanted = ADVERTISED_100baseT_Half;
> -		else if (speed_wanted == SPEED_100 &&
> -			 duplex_wanted == DUPLEX_FULL)
> -			advertising_wanted = ADVERTISED_100baseT_Full;
> -		else if (speed_wanted == SPEED_1000 &&
> -			 duplex_wanted == DUPLEX_HALF)
> -			advertising_wanted = ADVERTISED_1000baseT_Half;
> -		else if (speed_wanted == SPEED_1000 &&
> -			 duplex_wanted == DUPLEX_FULL)
> -			advertising_wanted = ADVERTISED_1000baseT_Full;
> -		else
> +	if ((autoneg_wanted == AUTONEG_ENABLE) && (advertising_wanted < 0)) {


This will change existing behavior of the tool, AFAICS.

	Jeff


