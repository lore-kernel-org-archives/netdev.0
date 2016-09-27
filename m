From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/3] net: bcmgenet: only use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 27 Sep 2016 07:43:42 -0400 (EDT)
Message-ID: <20160927.074342.1048165536305147870.davem@davemloft.net>
References: <1474921917-4773-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, jaedon.shin@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46152 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932192AbcI0Lnp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 07:43:45 -0400
In-Reply-To: <1474921917-4773-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 26 Sep 2016 22:31:54 +0200

> Some times ago, a serie of patches were committed :
> - commit 62469c76007e ("net: ethernet: bcmgenet: use phydev from struct net_device")
> - commit 6b352ebccbcf ("net: ethernet: broadcom: bcmgenet: use new api ethtool_{get|set}_link_ksettings")
> The first patch add a regression on this driver, so it should be reverted.
> As the second patch depend on the former, it should be reverted too.
> 
> The first patch is buggy because there is a "trick" in this driver.
> The structure phydev is kept in the private data when the interface
> go down, and used when the interface go up to enable the phy before
> the function phy_connect is called.
> 
> I don't have this hardware, neither the datasheet. So I won't
> update the driver to avoid this trick.
> 
> But the real goal of the first serie was to move to the new api
> ethtool_{get|set}_link_ksettings. So I provide a new version of
> the patch without the "cleaning" of driver to use the phydev
> store in the net_device structure.
> 
> Changelog:
> v3:
> - use priv instead of dev (so all the code use the same phydev)
> v2:
> - use Florian Fainelli patches for the revert instead of Jaedon Shin
> - simply use net: bcmgenet: for the prefix of the patch

Series applied, thanks.
