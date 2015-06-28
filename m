From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] net: phy: fix phy link up when limiting speed
 via device tree
Date: Sun, 28 Jun 2015 16:59:36 -0700 (PDT)
Message-ID: <20150628.165936.1506411757336657884.davem@davemloft.net>
References: <1435251062-5287-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbbF1X7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 19:59:37 -0400
In-Reply-To: <1435251062-5287-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Thu, 25 Jun 2015 22:21:02 +0530

> When limiting phy link speed using "max-speed" to 100mbps or less on a
> giga bit phy, phy never completes auto negotiation and phy state
> machine is held in PHY_AN. Fixing this issue by comparing the giga
> bit advertise though phydev->supported doesn't have it but phy has
> BMSR_ESTATEN set. So that auto negotiation is restarted as old and
> new advertise are different and link comes up fine.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied and queued up for -stable, thanks.
