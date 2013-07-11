From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ifb: fix rcu_sched self-detected stalls
Date: Wed, 10 Jul 2013 18:44:35 -0700 (PDT)
Message-ID: <20130710.184435.1686234758615260434.davem@davemloft.net>
References: <51DCDD32.30102@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, kaber@trash.net, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab3GKBog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 21:44:36 -0400
In-Reply-To: <51DCDD32.30102@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 10 Jul 2013 12:04:02 +0800

> According to the commit 16b0dc29c1af9df341428f4c49ada4f626258082
> (dummy: fix rcu_sched self-detected stalls)
> 
> Eric Dumazet fix the problem in dummy, but the ifb will occur the
> same problem like the dummy modules.
> 
> Trying to "modprobe ifb numifbs=30000" triggers :
> 
> INFO: rcu_sched self-detected stall on CPU
> 
> After this splat, RTNL is locked and reboot is needed.
> 
> We must call cond_resched() to avoid this, even holding RTNL.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied and queued up for -stable, thanks.
