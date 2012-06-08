From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] net/ethernet: ks8851_mll unregister_netdev() before
 freeing
Date: Fri, 8 Jun 2012 15:53:06 +0300
Message-ID: <20120608125306.GN4400@mwanda>
References: <20120606063129.GA26829@elgon.mountain>
 <20120607.131544.346298142594197233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raffaele.recalcati@bticino.it, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:43878 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab2FHMxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 08:53:22 -0400
Content-Disposition: inline
In-Reply-To: <20120607.131544.346298142594197233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 07, 2012 at 01:15:44PM -0700, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Wed, 6 Jun 2012 09:31:29 +0300
> 
> > We added another error condition here, but if we were to hit it then
> > we need to unregister_netdev() before doing the free_netdev().
> > Otherwise we would hit the BUG_ON() in free_netdev():
> > 
> > 	BUG_ON(dev->reg_state != NETREG_UNREGISTERED);
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Applied, but please be explicit that your patch is against one
> tree or another.  This one was for net-next only, but I tried
> initially to apply it to net which failed.

Sorry about that.  Will be more careful in the future.

regards,
dan carpenter
