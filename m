From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: dsa: two small bug fixes
Date: Thu, 11 Dec 2014 21:00:45 -0500 (EST)
Message-ID: <20141211.210045.470436808895185246.davem@davemloft.net>
References: <1418330956-17151-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, computersforpeace@gmail.com,
	andrey.volkov@nexvision.fr
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758641AbaLLCNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 21:13:44 -0500
In-Reply-To: <1418330956-17151-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 11 Dec 2014 12:49:14 -0800

> Here are two small fixes for the DSA slave interface creation code:
> 
> - first patch fixes a null pointer de-reference with an invalid PHY
>   device pointer while calling phy_connect_direct()
> 
> - second path propagates the dsa_slave_phy_setup() error code down to
>   its caller: dsa_slave_create

Series applied.

Please give me some feedback on the FIXED_PHY Kconfig issue I
asked you about earlier today.

Thanks.
