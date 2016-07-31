From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] tipc: fix imbalance read_unlock_bh in
 __tipc_nl_add_monitor()
Date: Sat, 30 Jul 2016 20:38:43 -0700 (PDT)
Message-ID: <20160730.203843.632827280409597213.davem@davemloft.net>
References: <1469671669-12829-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbcGaDip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 23:38:45 -0400
In-Reply-To: <1469671669-12829-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 28 Jul 2016 02:07:49 +0000

> In the error handling case of nla_nest_start() failed read_unlock_bh()
> is called  to unlock a lock that had not been taken yet. sparse warns
> about the context imbalance as the following:
> 
> net/tipc/monitor.c:799:23: warning:
>  context imbalance in '__tipc_nl_add_monitor' - different lock contexts for basic block
> 
> Fixes: cf6f7e1d5109 ('tipc: dump monitor attributes')
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.
