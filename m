From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] dsa: fix master interface allmulti/promisc handling
Date: Mon, 10 Nov 2008 21:53:22 -0800 (PST)
Message-ID: <20081110.215322.106664497.davem@davemloft.net>
References: <20081109232309.GE32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54631
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751122AbYKKFxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 00:53:22 -0500
In-Reply-To: <20081109232309.GE32552@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 10 Nov 2008 00:23:09 +0100

> Before commit b6c40d68ff6498b7f63ddf97cf0aa818d748dee7 ("net: only
> invoke dev->change_rx_flags when device is UP"), the dsa driver could
> sort-of get away with only fiddling with the master interface's
> allmulti/promisc counts in ->change_rx_flags() and not touching them
> in ->open() or ->stop().  After this commit (note that it was merged
> almost simultaneously with the dsa patches, which is why this wasn't
> caught initially), the breakage that was already there became more
> apparent.
> 
> Since it makes no sense to keep the master interface's allmulti or
> promisc count pinned for a slave interface that is down, copy the vlan
> driver's sync logic (which does exactly what we want) over to dsa to
> fix this.
> 
> Bug report from Dirk Teurlings <dirk@upexia.nl> and Peter van Valderen
> <linux@ddcrew.com>.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> Tested-by: Dirk Teurlings <dirk@upexia.nl>
> Tested-by: Peter van Valderen <linux@ddcrew.com>

Also applied, thanks a lot.
