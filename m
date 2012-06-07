From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/ethernet: ks8851_mll unregister_netdev() before
 freeing
Date: Thu, 07 Jun 2012 13:15:44 -0700 (PDT)
Message-ID: <20120607.131544.346298142594197233.davem@davemloft.net>
References: <20120606063129.GA26829@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raffaele.recalcati@bticino.it, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517Ab2FGUPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:15:45 -0400
In-Reply-To: <20120606063129.GA26829@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 6 Jun 2012 09:31:29 +0300

> We added another error condition here, but if we were to hit it then
> we need to unregister_netdev() before doing the free_netdev().
> Otherwise we would hit the BUG_ON() in free_netdev():
> 
> 	BUG_ON(dev->reg_state != NETREG_UNREGISTERED);
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, but please be explicit that your patch is against one
tree or another.  This one was for net-next only, but I tried
initially to apply it to net which failed.
