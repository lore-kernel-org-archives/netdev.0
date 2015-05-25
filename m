From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: bcm7xxx: Fix 7425 PHY ID and flags
Date: Mon, 25 May 2015 00:16:35 -0400 (EDT)
Message-ID: <20150525.001635.502403543821394724.davem@davemloft.net>
References: <1432328850-29065-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbbEYEQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 00:16:37 -0400
In-Reply-To: <1432328850-29065-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 22 May 2015 14:07:30 -0700

> While adding support for 7425 PHY in the 7xxx PHY driver, the ID that
> was used was actually coming from an external PHY: a BCM5461x. Fix this
> by using the proper ID for the internal 7425 PHY and set the
> PHY_IS_INTERNAL flag, otherwise consumers of this PHY driver would not
> be able to properly identify it as such.
> 
> Fixes: d068b02cfdfc2 ("net: phy: add BCM7425 and BCM7429 PHYs")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thank you.
