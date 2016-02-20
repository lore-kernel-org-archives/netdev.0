From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bcmgenet: Fix internal PHY link state
Date: Fri, 19 Feb 2016 23:52:12 -0500 (EST)
Message-ID: <20160219.235212.2155119722081137261.davem@davemloft.net>
References: <1455857330-18092-1-git-send-email-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, pgynther@google.com,
	opendmb@gmail.com
To: jaedon.shin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993177AbcBTEwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 23:52:14 -0500
In-Reply-To: <1455857330-18092-1-git-send-email-jaedon.shin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaedon Shin <jaedon.shin@gmail.com>
Date: Fri, 19 Feb 2016 13:48:50 +0900

> The PHY link state is not chaged in GENETv2 caused by the previous
> commit 49f7a471e4d1 ("net: bcmgenet: Properly configure PHY to ignore
> interrupt") was set to PHY_IGNORE_INTERRUPT in bcmgenet_mii_probe().
> 
> The internal PHY should use phy_mac_interrupt() when not in use
> PHY_POLL. The statement for phy_mac_interrupt() has two conditions. The
> first condition to check GENET_HAS_MDIO_INTR is not related PHY link
> state, so this patch removes it.
> 
> Fixes: 49f7a471e4d1 ("net: bcmgenet: Properly configure PHY to ignore interrupt")
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>

Applied, thanks.
