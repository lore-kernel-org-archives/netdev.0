From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] of: mdio: honor flags passed to of_phy_connect
Date: Tue, 16 Sep 2014 16:39:51 -0400 (EDT)
Message-ID: <20140916.163951.1456738615389200706.davem@davemloft.net>
References: <1410889776-11107-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbaIPUjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:39:53 -0400
In-Reply-To: <1410889776-11107-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 16 Sep 2014 10:49:36 -0700

> Commit f9a8f83b04e0 ("net: phy: remove flags argument from phy_{attach,
> connect, connect_direct}") removed the flags argument to the PHY library
> calls to: phy_{attach,connect,connect_direct}.
> 
> Most Device Tree aware drivers call of_phy_connect() with the flag
> argument set to 0, but some of them might want to set a different value
> there in order for the PHY driver to key a specific behavior based on
> the phy_device::dev_flags value.
> 
> Allow such drivers to set custom dev_flags as part of the
> of_phy_connect() call since of_phy_connect() does start the PHY state
> machine, it will call into the PHY driver config_init() callback which
> is usually where a specific phy_flags value is important.
> 
> Fixes: f9a8f83b04e0 ("net: phy: remove flags argument from phy_{attach, connect, connect_direct}")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

I do not see anyone passing non-zero in as the flags argument.

It is difficult for me to determine the impact of this patch,
whether it should really go to 'net' and/or 'stable', etc.
if you don't tell me who this could possibly break.

It's even worse when I do all of the searching around and
cannot find a breakage case myself. :-/
