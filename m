From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phy/ethtool: Add missing SPEED_<foo> strings
Date: Sun, 2 Apr 2017 23:40:31 +0200
Message-ID: <20170402214031.GH5189@lunn.ch>
References: <7a10ea1f8a35c40fd721e15f3643c99d98cca7d8.1491168585.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7a10ea1f8a35c40fd721e15f3643c99d98cca7d8.1491168585.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 02, 2017 at 02:30:06PM -0700, Joe Perches wrote:
> Add all the currently available SPEED_<foo> strings.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
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

Hi Joe

Given that this list is getting longer and longer, and the comment
that 0..INT_MAX are legal, is it time to replace this with something
dynamic?

	Andrew
