From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tipc: convert name table read-write lock
 to RCU
Date: Mon, 08 Dec 2014 20:41:08 -0500 (EST)
Message-ID: <20141208.204108.1710072779629475092.davem@davemloft.net>
References: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, richard.alpe@ericsson.com,
	tero.aho@coriant.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755469AbaLIBlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:41:12 -0500
In-Reply-To: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 2 Dec 2014 15:00:22 +0800

> Now TIPC name table is statically allocated and is protected with a
> Read-Write lock. To enhance the performance of TIPC name table lookup,
> we are going to involve RCU lock to protect the name table. As a
> consequence, it becomes lockless to concurrently look up name table on
> read side. However, before the conversion can be successfully made,
> the following two things must be first done:
> 
> - change allocation way of name table from static to dynamic
> - fix several incorrect locking policy issues

Series applied, thanks.
