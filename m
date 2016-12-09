From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: ethernet: Make sure we set dev->dev.parent
Date: Thu, 08 Dec 2016 21:27:15 -0500 (EST)
Message-ID: <20161208.212715.871055888687474629.davem@davemloft.net>
References: <20161208194125.13264-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madalin.bucur@nxp.com, johan@kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932771AbcLIC1S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 21:27:18 -0500
In-Reply-To: <20161208194125.13264-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  8 Dec 2016 11:41:23 -0800

> This patch series builds atop:
> 
> ec988ad78ed6d184a7f4ca6b8e962b0e8f1de461 ("phy: Don't increment MDIO bus
> refcount unless it's a different owner")
> 
> FMAN is the one that potentially needs patching as well (call SET_NETDEV_DEV),
> but there appears to be no way that init_phy is called right now, or there is
> not such an in-tree user. Madalin, can you comment on that?

Series applied, thanks.
