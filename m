From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] Circular dependency introduced in commit 86f6cf4127
Date: Wed, 25 Jun 2014 15:40:57 -0700 (PDT)
Message-ID: <20140625.154057.1098838428988383751.davem@davemloft.net>
References: <53AAEE62.7010602@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zonque@gmail.com, f.fainelli@gmail.com, netdev@vger.kernel.org
To: jeffm@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbaFYWk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 18:40:59 -0400
In-Reply-To: <53AAEE62.7010602@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Mahoney <jeffm@suse.com>
Date: Wed, 25 Jun 2014 11:44:34 -0400

> Commit 86f6cf4127 (net: of_mdio: add of_mdiobus_link_phydev())
> introduced a circular dependency between libphy and of_mdio.
> 
> depmod: ERROR: <modroot>/kernel/drivers/net/phy/libphy.ko in
> dependency cycle!
> depmod: ERROR: <modroot>/kernel/drivers/of/of_mdio.ko in dependency cycle!

Yeah, of_mdio.c references &mdio_bus_type and libphy now references
of_mdiobus_link_phydev.

Daniel, please work on fixing this, thanks.
