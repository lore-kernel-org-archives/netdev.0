From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/21] NET: use unique MDIO bus names
Date: Tue, 10 Jan 2012 16:35:24 -0800 (PST)
Message-ID: <20120110.163524.906859005643528607.davem@davemloft.net>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756667Ab2AKAf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 19:35:28 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Tue, 10 Jan 2012 10:59:06 +0100

> While troubleshooting an issue with an user of the RDC r6040 driver
> having compiled support for the fixed MDIO bus, I noticed that quite
> some network drivers will have a MDIO bus named "0" most of the time.
> 
> Some network drivers already try to provide an unique MDIO bus name
> using their PCI slot and function, this is okay.
> 
> Some other network drivers will format the name using their platform_device
> id, which will usually result in a collision with the fixed MDIO bus
> name ("0"), these drivers are fixed to use the following pattern instead:
> 
> <platform_device name>-<platform device id> which is unique
> 
> Finally the MDIO bus drivers themselves are patched to use an unique name
> as well.
> 
> There is a potential to break user-space applications assuming there is a
> specific MDIO bus named "0", "1" or other non-explanatory names like this.
> 
> Note that I compile tested most of the drivers on x86 and MIPS, ARM and Blackfin
> drivers have not been compile tested.

All applied, thanks Florian.
