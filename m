From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev/phy: Use mdiobus_read() so that proper locks
 are taken.
Date: Fri, 30 Sep 2011 18:54:21 -0400 (EDT)
Message-ID: <20110930.185421.252729993071152404.davem@davemloft.net>
References: <1317419482-25655-1-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: david.daney@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38069 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab1I3Wyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 18:54:33 -0400
In-Reply-To: <1317419482-25655-1-git-send-email-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>
Date: Fri, 30 Sep 2011 14:51:22 -0700

> Accesses to the mdio busses must be done with the mdio_lock to ensure
> proper operation.  Conveniently we have the helper function
> mdiobus_read() to do that for us.  Lets use it in get_phy_id() instead
> of accessing the bus without the lock held.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied to net-next.
