From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: of_mdio: fix of_set_phy_supported after
 driver probing
Date: Fri, 14 Feb 2014 15:52:18 -0500 (EST)
Message-ID: <20140214.155218.1787090679183722329.davem@davemloft.net>
References: <1392326088-3990-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333AbaBNUwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 15:52:20 -0500
In-Reply-To: <1392326088-3990-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 13 Feb 2014 13:14:48 -0800

> Commit 8fdade4 ("net: of_mdio: parse "max-speed" property to set PHY
> supported features") introduced a typo in of_set_phy_supported for the
> first assignment of phydev->supported which will not effectively limit
> the PHY device supported features bits if the PHY driver contains
> "higher" features (e.g: max-speed = <100> and PHY driver has
> PHY_GBIT_FEATURES set).
> 
> Fix this by making sure that the very first thing is to reset to sane
> defaults (PHY_BASIC_FEATURES) and then progressively add speed features
> as we parse them.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
