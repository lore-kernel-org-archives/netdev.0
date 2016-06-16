From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix suspicious RCU usage
Date: Wed, 15 Jun 2016 21:47:48 -0700 (PDT)
Message-ID: <20160615.214748.872094820538617710.davem@davemloft.net>
References: <1465971057-16660-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, erik.hugne@gmail.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbcFPEru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 00:47:50 -0400
In-Reply-To: <1465971057-16660-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 15 Jun 2016 14:10:57 +0800

> When run tipcTS&tipcTC test suite, the following complaint appears:
 ...
> The warning appears as rtnl_dereference() is wrongly used in
> tipc_l2_send_msg() under RCU read lock protection. Instead the proper
> usage should be that rcu_dereference_rtnl() is called here.
> 
> Fixes: 5b7066c3dd24 ("tipc: stricter filtering of packets in bearer layer")
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied.
