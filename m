From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND 0/2] fix rculist sparse errors
Date: Wed, 10 Dec 2014 13:49:21 -0500 (EST)
Message-ID: <20141210.134921.191006187867269911.davem@davemloft.net>
References: <1418201167-9591-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, eric.dumazet@gmail.com,
	jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, kbuild-all@01.org,
	linux-kernel@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46665 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932723AbaLJStY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 13:49:24 -0500
In-Reply-To: <1418201167-9591-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 10 Dec 2014 16:46:05 +0800

> When hlist_for_each_entry_continue_rcu_bh() gets "next" pointer of
> hlist_node structure through rcu_dereference_bh(), sparse warning
> appears as the "next" pointer is not annotated as __rcu. So if
> the "next" pointer is accessed with hlist_next_rcu() macro, the
> __rcu annotation will be added to the pointer. As a consequence,
> sparse warning is eliminated too.
> 
> The similar errors also appear in hlist_for_each_entry_continue_rcu()
> and hlist_for_each_entry_from_rcu().
> 
> In this version, CC more people like Paul E. McKenney and lkml mail
> list.

The rculist.h changes should go via Paul's tree, not mine.
