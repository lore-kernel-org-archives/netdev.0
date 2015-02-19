From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Indirect phy access for mv88e6171
Date: Thu, 19 Feb 2015 15:54:25 -0500 (EST)
Message-ID: <20150219.155425.1540670407178942108.davem@davemloft.net>
References: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbbBSUy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 15:54:27 -0500
In-Reply-To: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat, 14 Feb 2015 19:17:49 +0100

> These two patches allow the mv88e6171 driver to access the port phys
> using indirect addressing. Depending on pin strapping, the switch
> either uses a single address on the host MDIO bus, requiring the port
> phys are accessed indirectly, or the switch uses a number of addresses
> on the host bus and the phys can be directly accessed.
> 
> The 370RD, the first supported platform to use the 6171 uses multiple
> addresses, so this indirect mode was not required. However the
> WRT1900AC has the switch configured to use a single address, and so
> indirect access is needed.
> 
> The mv88e6352 already has all the needed code. Refactor it into the
> shared mv88e6xxx and then use it in the mv88e6171 driver.
> 
> Tested on the 370RD and WRT1900AC.
> 
> It would be good if Guenter Roeck could test on his platform to ensure
> i've not broken anything for the mv88e6352.

Series applied, thanks.
