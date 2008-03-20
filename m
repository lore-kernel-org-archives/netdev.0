From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] FIB_TRIE: RCU refine
Date: Thu, 20 Mar 2008 08:35:44 -0700
Message-ID: <20080320083544.581d309c@extreme>
References: <47E1F2DB.20204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33494 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756380AbYCTPfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 11:35:50 -0400
In-Reply-To: <47E1F2DB.20204@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> David, sorry to send this patch again.
> I sent it yesterday, but seems that it was refused by
> netdev maillist. I subscribed the mailist and send it
> again.
> 
> On reader side, RCU list-traversal functions, such as
> *list_for_each_entry_rcu(), should be within an RCU
> read-side critical section.
> 
> Surround them by rcu_read_*lock()

This patch is unnecessary since rcu_read_lock is already fib_trie_seq_start
and fib_trie_seq_stop.
