From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: do not call phy_start_aneg
Date: Sat, 04 Oct 2014 20:45:17 -0400 (EDT)
Message-ID: <20141004.204517.857778573109570110.davem@davemloft.net>
References: <1412301363-8478-1-git-send-email-f.fainelli@gmail.com>
	<1412301363-8478-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbaJEApS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:45:18 -0400
In-Reply-To: <1412301363-8478-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  2 Oct 2014 18:56:03 -0700

> Commit f7f1de51edbd ("net: dsa: start and stop the PHY state machine")
> add calls to phy_start() in dsa_slave_open() respectively phy_stop() in
> dsa_slave_close().
> 
> We also call phy_start_aneg() in dsa_slave_create(), and this call is
> messing up with the PHY state machine, since we basically start the
> auto-negotiation, and later on restart it when calling phy_start().
> phy_start() does not currently handle the PHY_FORCING or PHY_AN states
> properly, but such a fix would be too invasive for this window.
> 
> Fixes: f7f1de51edbd ("net: dsa: start and stop the PHY state machine")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
