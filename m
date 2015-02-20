From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Fix verification of EEE support in
 phy_init_eee
Date: Fri, 20 Feb 2015 15:30:35 -0500 (EST)
Message-ID: <20150220.153035.1886044606040028963.davem@davemloft.net>
References: <1424194582-9792-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	peppe.cavallaro@st.com
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbbBTUai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:30:38 -0500
In-Reply-To: <1424194582-9792-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 17 Feb 2015 09:36:22 -0800

> phy_init_eee uses phy_find_setting(phydev->speed, phydev->duplex)
> to find a valid entry in the settings array for the given speed
> and duplex value. For full duplex 1000baseT, this will return
> the first matching entry, which is the entry for 1000baseKX_Full.
> 
> If the phy eee does not support 1000baseKX_Full, this entry will not
> match, causing phy_init_eee to fail for no good reason.
> 
> Fixes: 9a9c56cb34e6 ("net: phy: fix a bug when verify the EEE support")
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, and queued up for -stable, thanks.
