From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 00/22] Support MDIO devices
Date: Thu, 07 Jan 2016 14:33:57 -0500 (EST)
Message-ID: <20160107.143357.139530014387548318.davem@davemloft.net>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbcAGTeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:34:02 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed,  6 Jan 2016 20:11:05 +0100

> The discussions about changing the way DSA probes switches resulted in
> the wish to have switches attached to an MDIO bus to be represented as
> an MDIO device. However the current code only supports PHYs on MDIO
> busses. This patchset remedies this problem. It consists of a number
> of cleanups, abstraction for accessing structure members, and
> refactoring, as well as adding the concept of a generic MDIO device
> and MDIO driver.
> 
> v2:
> Added Reviewed-by from Florian
> Made phydev_name() an inline function
> Added phy_attached_info/phy_attached_print() for information about
> the attached phy.
> Removed now redundant irq setup from of_mdio.c
> Dropped hunks from PHYMII ioctl which prevented access to any address
> DSA carrier off before phy setup

Series applied, thanks Andrew.
