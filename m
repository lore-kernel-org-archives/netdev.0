From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Do not override PHY interface if already
 configured
Date: Wed, 12 Aug 2015 14:30:35 -0700 (PDT)
Message-ID: <20150812.143035.511637354777280164.davem@davemloft.net>
References: <1439063937-16316-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, linux@roeck-us.net
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbHLVai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:30:38 -0400
In-Reply-To: <1439063937-16316-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat,  8 Aug 2015 12:58:57 -0700

> In case we need to divert reads/writes using the slave MII bus, we may have
> already fetched a valid PHY interface property from Device Tree, and that
> mode is used by the PHY driver to make configuration decisions.
> 
> If we could not fetch the "phy-mode" property, we will assign p->phy_interface
> to PHY_INTERFACE_MODE_NA, such that we can actually check for that condition as
> to whether or not we should override the interface value.
> 
> Fixes: 19334920eaf7 ("net: dsa: Set valid phy interface type")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Hi Guenter,
> 
> Could you verify this does not break what you were trying to fix with your change?
> I am fairly confident this will not because for "PHYs" built-into the switch port
> we will not be able to fetch a "phy-mode" property from DT, so we will use
> PHY_INTERFACE_MODE_NA, but here, we will re-assign them to PHY_INTERFACE_MODE_GMII
> as before.

I was trying to wait for Guenter's testing before applying this, but it's been some
time already and it makes no sense to wait any longer.

Applied to 'net', thanks Florian.
