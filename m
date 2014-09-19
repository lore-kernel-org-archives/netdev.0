From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/8] net: phy: Broadcom BCM7xxx PHY
 workaround update
Date: Fri, 19 Sep 2014 16:27:34 -0400 (EDT)
Message-ID: <20140919.162734.2072914871245072340.davem@davemloft.net>
References: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757483AbaISU1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:27:36 -0400
In-Reply-To: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 19 Sep 2014 13:07:48 -0700

> This patch sets the change to of_phy_connect() that you have seen before,
> this time with the full context of why it is useful and applicable here.
> 
> Due to some design decision, the internal PHY on Broadcom BCM7xxx chips
> is not entirely self contained and does not report its internal revision
> through MII_PHYSID2, that is left to external PHY designs.
> 
> This forces us to get the PHY revision from the GENET and SF2 switch drivers
> because those two peripherals integrate such a PHY and do contain the PHY
> revision in their registers.
> 
> The approach taken here is hopefully easy to extend to similar needs for
> other chips/ as well.

Applied, thanks for fixing things up so fast.
