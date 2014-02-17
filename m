From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] net: phy: allow PHY drivers to implement
 their own software reset
Date: Mon, 17 Feb 2014 16:23:43 -0500 (EST)
Message-ID: <20140217.162343.325745613056866328.davem@davemloft.net>
References: <1392670366-31457-1-git-send-email-f.fainelli@gmail.com>
	<1392670366-31457-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbaBQVXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:23:45 -0500
In-Reply-To: <1392670366-31457-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 17 Feb 2014 12:52:45 -0800

> +	if (phydev->drv->soft_reset(phydev))
> +		ret = phydev->drv->soft_reset(phydev);

You're not testing if the method is NULL, you're actually invoking it.
