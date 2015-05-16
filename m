From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: Add state machine state transitions
 debug prints
Date: Fri, 15 May 2015 21:24:05 -0400 (EDT)
Message-ID: <20150515.212405.1595137643453957744.davem@davemloft.net>
References: <1431724722-14737-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992645AbbEPBYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 21:24:06 -0400
In-Reply-To: <1431724722-14737-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 May 2015 14:18:42 -0700

> @@ -311,6 +311,30 @@ enum phy_state {
>  	PHY_RESUMING
>  };
>  
> +#define PHY_STATE_STR(_state)			\
> +	case PHY_##_state:			\
> +		return __stringify(_state);	\
> +
> +static inline const char *phy_state_to_str(enum phy_state st)
> +{

Please put this into drivers/net/phy/phy.c as it's the only user.

This lines up with phy_speed_to_str() etc.
