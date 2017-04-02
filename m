From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy/ethtool: Add missing SPEED_<foo> strings
Date: Sun, 2 Apr 2017 15:29:51 -0700
Message-ID: <c7baf39b-4d4a-93f2-6975-d170a53a6ef2@gmail.com>
References: <7a10ea1f8a35c40fd721e15f3643c99d98cca7d8.1491168585.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36792 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbdDBW3x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 18:29:53 -0400
In-Reply-To: <7a10ea1f8a35c40fd721e15f3643c99d98cca7d8.1491168585.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/02/17 à 14:30, Joe Perches a écrit :
> Add all the currently available SPEED_<foo> strings.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Considering that PHYLIB does not support anything > 10Gbs at the moment,
I am not sure how useful that is except if we wanted to re-use
phy_speed_to_str() in other places of the kernel?

> ---
>  drivers/net/phy/phy.c        | 14 ++++++++++++++
>  include/uapi/linux/ethtool.h |  1 +
>  2 files changed, 15 insertions(+)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index d019bbf42c31..e7d0367a1455 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -50,8 +50,22 @@ static const char *phy_speed_to_str(int speed)
>  		return "1Gbps";
>  	case SPEED_2500:
>  		return "2.5Gbps";
> +	case SPEED_5000:
> +		return "5Gbps";
>  	case SPEED_10000:
>  		return "10Gbps";
> +	case SPEED_20000:
> +		return "20Gbps";
> +	case SPEED_25000:
> +		return "25Gbps";
> +	case SPEED_40000:
> +		return "40Gbps";
> +	case SPEED_50000:
> +		return "50Gbps";
> +	case SPEED_56000:
> +		return "56Gbps";
> +	case SPEED_100000:
> +		return "100Gbps";
>  	case SPEED_UNKNOWN:
>  		return "Unknown";
>  	default:
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 3dc91a46e8b8..5f4ea28eabe4 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1487,6 +1487,7 @@ enum ethtool_link_mode_bit_indices {
>   */
>  
>  /* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal. */
> +/* Update drivers/net/phy/phy.c:phy_speed_to_str() when adding new values */
>  #define SPEED_10		10
>  #define SPEED_100		100
>  #define SPEED_1000		1000
> 


-- 
Florian
