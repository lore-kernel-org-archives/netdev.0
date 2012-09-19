From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dev: fix incorrect getting net device's
 name
Date: Wed, 19 Sep 2012 15:37:24 -0400 (EDT)
Message-ID: <20120919.153724.1218581037036054616.davem@davemloft.net>
References: <1347605907-3884-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab2ISTh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:37:26 -0400
In-Reply-To: <1347605907-3884-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Fri, 14 Sep 2012 14:58:27 +0800

> When moving a nic from net namespace A to net namespace B,
> in dev_change_net_namesapce,we call __dev_get_by_name to
> decide if the netns B has the device has the same name.
> 
> if the netns B already has the same named device,we call
> dev_get_valid_name to try to get a valid name for this nic in
> the netns B,but net_device->nd_net still point to netns A now.
> 
> this patch fix it.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Looks good, applied, thanks!
