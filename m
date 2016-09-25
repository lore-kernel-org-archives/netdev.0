From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "net: ethernet: bcmgenet: use phydev from
 struct net_device"
Date: Sat, 24 Sep 2016 20:10:54 -0400 (EDT)
Message-ID: <20160924.201054.1736819083455070537.davem@davemloft.net>
References: <1474747110-6496-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42446 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935087AbcIYAK5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 20:10:57 -0400
In-Reply-To: <1474747110-6496-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 24 Sep 2016 12:58:30 -0700

> There is already a commit:
> 
> Revert "net: ethernet: bcmgenet: use phy_ethtool_{get|set}_link_ksettings"
> 
> which should make this apply cleanly to "net" now.

But look at net-next, it got re-added there.

This is going to be a bit of a merge hassle, and this is why I pushed
back on the other attempt to revert this thing.
