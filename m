From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r6040: check MDIO register busy waiting result
Date: Wed, 06 Mar 2013 15:42:36 -0500 (EST)
Message-ID: <20130306.154236.523305999328373804.davem@davemloft.net>
References: <1362566492-28176-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803Ab3CFUmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 15:42:38 -0500
In-Reply-To: <1362566492-28176-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed,  6 Mar 2013 11:41:32 +0100

> We are currently busy waiting for MDIO registers to complete their
> operation but we did not propagate the result back to the caller.
> Update r6040_phy_{read,write} to report the busy waiting result
> accordingly.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
