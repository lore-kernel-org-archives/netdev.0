From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Deregister multicast vxlan steering
 rules when going down
Date: Thu, 13 Mar 2014 13:36:13 -0400 (EDT)
Message-ID: <20140313.133613.1290687362543432702.davem@davemloft.net>
References: <1394715135-18791-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbaCMRgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 13:36:15 -0400
In-Reply-To: <1394715135-18791-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 13 Mar 2014 14:52:15 +0200

> When mlx4_en_stop_port() is called, we need to deregister also the
> tunnel steering rules that relate to multicast.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
> 
> Dave - this is a small fix which is addition to yesterday's set. 

Ok, applied, thanks.

> While on that, I noted that there are places where we do check for the 
> return value of mlx4_flow_detach() and print something, while in other places
> we don't. I will work on net-next patch that makes it consistent all across 
> the place by setting that to void, as we should be OK with the warning 
> which exists within mlx4_flow_detach()

Great, look forward to seeing those patches.
