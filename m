From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/5] ethtool: (uapi) Add ETHTOOL_PHY_GTUNABLE
 and ETHTOOL_PHY_STUNABLE
Date: Fri, 4 Nov 2016 13:03:43 +0100
Message-ID: <20161104120343.GI13959@lunn.ch>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
 <1478255742-25693-2-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com, cphealy@gmail.com, robh@kernel.org
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36801 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933126AbcKDMDp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 08:03:45 -0400
Content-Disposition: inline
In-Reply-To: <1478255742-25693-2-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2016 at 11:35:38AM +0100, Allan W. Nielsen wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Defines a generic API to get/set phy tunables. The API is using the
> existing ethtool_tunable/tunable_type_id types which is already being used
> for mac level tunables.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
> ---
>  include/uapi/linux/ethtool.h | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 8e54723..fd0bd36 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -248,6 +248,10 @@ struct ethtool_tunable {
>  	void	*data[0];
>  };
>  
> +enum phy_tunable_id {
> +	ETHTOOL_PHY_ID_UNSPEC,
> +};

Hi Allen

Do you have any idea what this is for? A grep for
ETHTOOL_TUNABLE_UNSPEC does not turn up anything.

       Andrew
