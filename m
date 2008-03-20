From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] FIB_TRIE: RCU refine
Date: Thu, 20 Mar 2008 15:14:10 -0700 (PDT)
Message-ID: <20080320.151410.131501950.davem@davemloft.net>
References: <47E1F2DB.20204@cn.fujitsu.com>
	<20080320083544.581d309c@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50537
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757595AbYCTWNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 18:13:54 -0400
In-Reply-To: <20080320083544.581d309c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 20 Mar 2008 08:35:44 -0700

> 
> > David, sorry to send this patch again.
> > I sent it yesterday, but seems that it was refused by
> > netdev maillist. I subscribed the mailist and send it
> > again.
> > 
> > On reader side, RCU list-traversal functions, such as
> > *list_for_each_entry_rcu(), should be within an RCU
> > read-side critical section.
> > 
> > Surround them by rcu_read_*lock()
> 
> This patch is unnecessary since rcu_read_lock is already fib_trie_seq_start
> and fib_trie_seq_stop.

COrrect.
