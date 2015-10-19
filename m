From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: Fix early link interrupt enabling
Date: Sun, 18 Oct 2015 23:07:56 -0700 (PDT)
Message-ID: <20151018.230756.854746194228547106.davem@davemloft.net>
References: <1445116966-27610-1-git-send-email-fainelli@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbJSFvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 01:51:39 -0400
In-Reply-To: <1445116966-27610-1-git-send-email-fainelli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 17 Oct 2015 14:22:46 -0700

> From: Florian Fainelli <f.fainelli@gmail.com>
> 
> Link interrupts are enabled in init_umac(), which is too early for us to
> process them since we do not yet have a valid PHY device pointer. On
> BCM7425 chips for instance, we will crash calling phy_mac_interrupt()
> because phydev is NULL.
> 
> Fix this by moving the link interrupts enabling in
> bcmgenet_netif_start(), under a specific function:
> bcmgenet_link_intr_enable() and while at it, update the comments
> surrounding the code.
> 
> Fixes: 6cc8e6d4dcb36 ("net: bcmgenet: Delay PHY initialization to bcmgenet_open()")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
