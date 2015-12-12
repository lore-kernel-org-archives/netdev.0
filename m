From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] phy: micrel: Fix finding PHY properties in MAC
 node.
Date: Fri, 11 Dec 2015 20:32:15 -0500 (EST)
Message-ID: <20151211.203215.437220060059895199.davem@davemloft.net>
References: <1449687391-15331-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	dinguyen@opensource.altera.com, david.daney@cavium.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755AbbLLBcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 20:32:17 -0500
In-Reply-To: <1449687391-15331-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed,  9 Dec 2015 19:56:31 +0100

> commit 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus,
> not the bus' parent.")  changed the parenting of PHY devices, making
> them a child of the MDIO bus, instead of the MAC device. This broken
> the Micrel PHY driver which has a deprecated feature of allowing PHY
> properties to be placed into the MAC node.
> 
> In order to find the MAC node, we need to walk up the tree of devices
> until we find one with an OF node attached.
> 
> Reported-by: Dinh Nguyen <dinguyen@opensource.altera.com>
> Suggested-by: David Daney <david.daney@cavium.com>
> Acked-by: David Daney <david.daney@cavium.com>
> Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied and queued up for -stable, thanks.
