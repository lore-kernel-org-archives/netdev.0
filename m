From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dwc_eth_qos: Reset hardware before PHY start
Date: Sat, 06 Feb 2016 03:38:46 -0500 (EST)
Message-ID: <20160206.033846.1879953214102776035.davem@davemloft.net>
References: <1454402342-20477-1-git-send-email-rabin.vincent@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: larper@axis.com, netdev@vger.kernel.org, rabinv@axis.com
To: rabin.vincent@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbcBFIit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 03:38:49 -0500
In-Reply-To: <1454402342-20477-1-git-send-email-rabin.vincent@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabin Vincent <rabin.vincent@axis.com>
Date: Tue, 2 Feb 2016 09:39:02 +0100

> From: Rabin Vincent <rabinv@axis.com>
> 
> The hardware reset is currently done after phy_start() is called,
> leading to a race where we can lose the link status if the phy state
> machine calls dwceqos_adjust_link() before we reset the MAC registers.
> 
> Acked-by: Lars Persson <larper@axis.com>
> Signed-off-by: Rabin Vincent <rabinv@axis.com>

Applied to 'net', thanks.
