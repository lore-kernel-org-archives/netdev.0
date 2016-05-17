From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: remove irq param to fix crash in fixed_phy_add()
Date: Tue, 17 May 2016 14:20:34 -0400 (EDT)
Message-ID: <20160517.142034.611823602956859056.davem@davemloft.net>
References: <1463397356-5656-1-git-send-email-rabin.vincent@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org,
	devicetree@vger.kernel.org, rabinv@axis.com
To: rabin.vincent@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbcEQSUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 14:20:36 -0400
In-Reply-To: <1463397356-5656-1-git-send-email-rabin.vincent@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabin Vincent <rabin.vincent@axis.com>
Date: Mon, 16 May 2016 13:15:56 +0200

> From: Rabin Vincent <rabinv@axis.com>
> 
> Since e7f4dc3536a ("mdio: Move allocation of interrupts into core"),
> platforms which call fixed_phy_add() before fixed_mdio_bus_init() is
> called (for example, because the platform code and the fixed_phy driver
> use the same initcall level) crash in fixed_phy_add() since the
> ->mii_bus is not allocated.
> 
> Also since e7f4dc3536a, these interrupts are initalized to polling by
> default.  All callers of both fixed_phy_register() and fixed_phy_add()
> pass PHY_POLL for the irq argument, so we can fix these crashes by
> simply removing the irq parameter, since the default is correct for all
> users.
> 
> Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
> Signed-off-by: Rabin Vincent <rabinv@axis.com>

Applied.
