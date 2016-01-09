From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 1/3] cxgb4: Add LRO infrastructure for
 cxgb4i driver
Date: Fri, 08 Jan 2016 21:53:25 -0500 (EST)
Message-ID: <20160108.215325.556490793545398776.davem@davemloft.net>
References: <1452158647-9714-1-git-send-email-hariprasad@chelsio.com>
	<1452158647-9714-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	JBottomley@odin.com, martin.petersen@oracle.com,
	leedom@chelsio.com, kxie@chelsio.com, manojmalviya@chelsio.com,
	nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754728AbcAICxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 21:53:30 -0500
In-Reply-To: <1452158647-9714-2-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu,  7 Jan 2016 14:54:05 +0530

> +	struct sk_buff *skb_head, *skb_tail; /* list of aggregated sessions */

Don't invent your own list scheme, use struct sk_buff_head and
the appropriate initializers and helpers.

If people do their own list handling, then it's extremely difficult
to change the skb queue implementation.
