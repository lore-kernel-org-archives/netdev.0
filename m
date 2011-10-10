From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] r6040: invoke phy_{start,stop} when
 appropriate
Date: Sun, 09 Oct 2011 23:51:12 -0400 (EDT)
Message-ID: <20111009.235112.1898284515095600745.davem@davemloft.net>
References: <201110071136.22107.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab1JJDvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 23:51:17 -0400
In-Reply-To: <201110071136.22107.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Fri, 7 Oct 2011 11:36:22 +0200

> Joe reported to me that right after a bring up of a r6040 interface
> the ethtool output had no consistent output with respect to link duplex
> and speed. Fix this by adding a missing phy_start call in r6040_up and
> conversely a phy_stop call in r6040_down to properly initialize phy states.
> 
> Reported-by: Joe Chou <Joe.Chou@rdc.com.tw>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
