From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-net] ipv6: Use hlist_for_each_entry_rcu_bh() in
 ipv6_chk_same_addr()
Date: Tue, 01 Nov 2011 03:53:23 -0400 (EDT)
Message-ID: <20111101.035323.458528114788135444.davem@davemloft.net>
References: <1320125455-25222-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940Ab1KAHx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 03:53:26 -0400
In-Reply-To: <1320125455-25222-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue,  1 Nov 2011 13:30:55 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> Replace hlist_for_each_entry and hlist_for_each_entry_rcu with
> hlist_for_each_entry_rcu_bh() in ipv6_chk_same_addr and
> ipv6_chk_addr to keep that all dereference methods for addr_list
> are same, and take advantage of _rcu_bh() critical section
> checking and prevention from compiler merging or refetching.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

Callers are already in an RCU section with BH disabled when these
functions are invoked.
