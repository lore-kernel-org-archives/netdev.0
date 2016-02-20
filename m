From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] phy: marvell/micrel: Fix Unpossible condition
Date: Fri, 19 Feb 2016 23:42:09 -0500 (EST)
Message-ID: <20160219.234209.1817149741397354640.davem@davemloft.net>
References: <1455924929-12462-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423636AbcBTEmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 23:42:11 -0500
In-Reply-To: <1455924929-12462-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat, 20 Feb 2016 00:35:29 +0100

> commit 2b2427d06426 ("phy: micrel: Add ethtool statistics counters")
> from Dec 30, 2015, leads to the following static checker
> warning:
> 
>         drivers/net/phy/micrel.c:609 kszphy_get_stat()
>         warn: unsigned 'val' is never less than zero.
 ...
> The same problem exists in the Marvell driver. Fix both.
> 
> Fixes: 2b2427d06426 ("phy: micrel: Add ethtool statistics counters")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Reported-by: Julia.Lawall <julia.lawall@lip6.fr>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
