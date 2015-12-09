From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: [PATCHv2 net] phy: micrel: Fix finding PHY properties in MAC
 node.
Date: Wed, 9 Dec 2015 13:39:21 -0600
Message-ID: <56688369.80706@opensource.altera.com>
References: <1449687391-15331-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	<david.daney@cavium.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0092.outbound.protection.outlook.com ([157.56.110.92]:16848
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751498AbbLIUCO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 15:02:14 -0500
In-Reply-To: <1449687391-15331-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2015 12:56 PM, Andrew Lunn wrote:
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
> ---
> v2: Remove include of netdev.h
> ---

Feel free to add:

Tested-by: Dinh Nguyen <dinguyen@opensource.altera.com>

Thanks,
Dinh
