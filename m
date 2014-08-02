From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: remove nested rcu_read_lock/unlock
Date: Sat, 02 Aug 2014 15:27:48 -0700 (PDT)
Message-ID: <20140802.152748.2171811750703626175.davem@davemloft.net>
References: <53DB2D04.6030909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbaHBW1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 18:27:49 -0400
In-Reply-To: <53DB2D04.6030909@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 1 Aug 2014 14:00:36 +0800

> 
> ip_local_deliver_finish() already have a rcu_read_lock/unlock, so
> the rcu_read_lock/unlock is unnecessary.
> 
> See the stack below:
> ip_local_deliver_finish
> 	|
> 	|
> 	->icmp_rcv
> 		|
> 		|
> 		->icmp_socket_deliver
> 
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied, thank you.
