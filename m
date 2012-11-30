From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnelink: remove unused parameter from
 rtnl_create_link().
Date: Fri, 30 Nov 2012 12:25:07 -0500 (EST)
Message-ID: <20121130.122507.1462357809313389723.davem@davemloft.net>
References: <1354273727-6336-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, jiri@resnulli.us
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab2K3RZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 12:25:09 -0500
In-Reply-To: <1354273727-6336-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Fri, 30 Nov 2012 13:08:47 +0200

> This patch removes an unused parameter (src_net) from rtnl_create_link() 
> method and from the method single invocation, in veth. 
> This parameter was used in the past when calling 
> ops->get_tx_queues(src_net, tb) in rtnl_create_link().  
> The get_tx_queues() member of rtnl_link_ops was replaced by two methods, 
> get_num_tx_queues() and get_num_rx_queues(), which do not get any 
> parameter. This was done in commit d40156aa5ecbd51fed932ed4813df82b56e5ff4d by 
> Jiri Pirko ("rtnl: allow to specify different num for rx and tx queue count").
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
