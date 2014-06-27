From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix circular dependency in of_mdio code
Date: Fri, 27 Jun 2014 00:26:26 -0700 (PDT)
Message-ID: <20140627.002626.309916119429166859.davem@davemloft.net>
References: <1403766631-11499-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffm@suse.com, f.fainelli@gmail.com, netdev@vger.kernel.org
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbaF0H01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 03:26:27 -0400
In-Reply-To: <1403766631-11499-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Thu, 26 Jun 2014 09:10:31 +0200

> Commit 86f6cf4127 (net: of_mdio: add of_mdiobus_link_phydev()) introduced a
> circular dependency between libphy and of_mdio.
> 
> depmod: ERROR: <modroot>/kernel/drivers/net/phy/libphy.ko in
> dependency cycle!
> depmod: ERROR: <modroot>/kernel/drivers/of/of_mdio.ko in dependency cycle!
> 
> The problem is that of_mdio.c references &mdio_bus_type and libphy now
> references of_mdiobus_link_phydev.
> 
> Fix this by not exporting of_mdiobus_link_phydev() from of_mdio.ko.
> Make it a static function in mdio_bus.c instead.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Reported-by: Jeff Mahoney <jeffm@suse.com>
> Fixes: 86f6cf4127 (net: of_mdio: add of_mdiobus_link_phydev())

Applied, thank you.
