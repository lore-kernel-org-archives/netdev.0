From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: cpsw: Correctly attach to GPIO bitbang MDIO
 driver
Date: Thu, 30 Jan 2014 16:26:00 -0800 (PST)
Message-ID: <20140130.162600.518784994857721019.davem@davemloft.net>
References: <1390991557-22522-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lukas.stockmann@siemens.com,
	mugunthanvnm@ti.com
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbaAaA0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 19:26:04 -0500
In-Reply-To: <1390991557-22522-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Wed, 29 Jan 2014 11:32:37 +0100

> When the GPIO bitbang MDIO driver is used instead of the Davinci MDIO driver
> we need to configure the phy_id string differently. Otherwise this string
> looks like this "gpio.6" instead of "gpio-0" and the PHY is not found when
> phy_connect() is called.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>

Applied.
