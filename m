From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Call bus->reset() after releasing PHYs
 from reset
Date: Thu, 11 May 2017 23:07:01 -0400 (EDT)
Message-ID: <20170511.230701.1656036521860703475.davem@davemloft.net>
References: <20170511182417.17708-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rogerq@ti.com, andrew@lunn.ch,
        linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdELDHG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 23:07:06 -0400
In-Reply-To: <20170511182417.17708-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 11 May 2017 11:24:16 -0700

> The API convention makes it that a given MDIO bus reset should be able
> to access PHY devices in its reset() callback and perform additional
> MDIO accesses in order to bring the bus and PHYs in a working state.
> 
> Commit 69226896ad63 ("mdio_bus: Issue GPIO RESET to PHYs.") broke that
> contract by first calling bus->reset() and then release all PHYs from
> reset using their shared GPIO line, so restore the expected
> functionality here.
> 
> Fixes: 69226896ad63 ("mdio_bus: Issue GPIO RESET to PHYs.")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
