From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: ensure Gigabit features are masked off
 if requested
Date: Tue, 04 Feb 2014 20:16:15 -0800 (PST)
Message-ID: <20140204.201615.549842021416642571.davem@davemloft.net>
References: <1391459746-2631-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcmvbkbc@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbaBEEQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:16:16 -0500
In-Reply-To: <1391459746-2631-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 3 Feb 2014 12:35:46 -0800

> When a Gigabit PHY device is connected to a 10/100Mbits capable Ethernet
> MAC, the driver will restrict the phydev->supported modes to mask off
> Gigabit. If the Gigabit PHY comes out of reset with the Gigabit features
> set by default in MII_CTRL1000, it will keep advertising these feature,
> so by the time we call genphy_config_advert(), the condition on
> phydev->supported having the Gigabit features on is false, and we do not
> update MII_CTRL1000 with updated values, and we keep advertising Gigabit
> features, eventually configuring the PHY for Gigabit whilst the Ethernet
> MAC does not support that.
> 
> This patches fixes the problem by ensuring that the Gigabit feature bits
> are always cleared in MII_CTRL1000, if the PHY happens to be a Gigabit
> PHY, and then, if Gigabit features are supported, setting those and
> updating MII_CTRL1000 accordingly.
> 
> Reported-by: Max Filippov <jcmvbkbc@gmail.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
