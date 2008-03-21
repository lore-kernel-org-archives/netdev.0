From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] FIB_TRIE: RCU refine
Date: Fri, 21 Mar 2008 08:19:40 +0800
Message-ID: <47E2FF1C.7060802@cn.fujitsu.com>
References: <47E1F2DB.20204@cn.fujitsu.com> <20080320083544.581d309c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56912 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750916AbYCUAWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 20:22:54 -0400
In-Reply-To: <20080320083544.581d309c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger said the following on 2008-3-20 23:35:
>> David, sorry to send this patch again.
>> I sent it yesterday, but seems that it was refused by
>> netdev maillist. I subscribed the mailist and send it
>> again.
>>
>> On reader side, RCU list-traversal functions, such as
>> *list_for_each_entry_rcu(), should be within an RCU
>> read-side critical section.
>>
>> Surround them by rcu_read_*lock()
> 
> This patch is unnecessary since rcu_read_lock is already fib_trie_seq_start
> and fib_trie_seq_stop.
> 

I see.
Thank you, Stephen.

