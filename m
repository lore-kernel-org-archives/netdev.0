From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] standardize TIPC SKB queue operations
Date: Wed, 26 Nov 2014 12:31:20 -0500 (EST)
Message-ID: <20141126.123120.2063090248645805847.davem@davemloft.net>
References: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, richard.alpe@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaKZRbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:31:23 -0500
In-Reply-To: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 26 Nov 2014 11:41:44 +0800

> Now the following SKB queues are created and maintained within internal
> TIPC stack:
> 
> - link transmission queue
> - link deferred queue
> - link receive queue
> - socket outgoing packet chain
> - name table outgoing packet chain
> 
> In order to manage above queues, TIPC stack declares a sk_buff pointer
> for each queue to record its head, and directly modifies "prev" and
> "next" SKB pointers of SKB structure when inserting or deleting a SKB
> to or from the queue. As these operations are pretty complex, they
> easily involve fatal mistakes. If these sk_buff pointers are replaced
> with sk_buff_head instances as queue heads and corresponding generic
> SKB list APIs are used to manage them, the entire TIPC code would
> become quite clean and readable. But before make the change, we need
> to clean up below redundant functionalities:
> 
> - remove node subscribe infrastructure
> - remove protocol message queue
> - remove retransmission queue
> - clean up process of pushing packets in link layer 

Series applied, thanks.
