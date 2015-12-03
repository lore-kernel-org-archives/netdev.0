From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: fix node reference count bug
Date: Thu, 03 Dec 2015 15:21:28 -0500 (EST)
Message-ID: <20151203.152128.176014435314901182.davem@davemloft.net>
References: <1449087577-7252-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426AbbLCUVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:21:30 -0500
In-Reply-To: <1449087577-7252-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed,  2 Dec 2015 15:19:37 -0500

> Commit 5405ff6e15f40f2f ("tipc: convert node lock to rwlock")
> introduced a bug to the node reference counter handling. When a
> message is successfully sent in the function tipc_node_xmit(),
> we return directly after releasing the node lock, instead of
> continuing and decrementing the node reference counter as we
> should do.
> 
> This commit fixes this bug.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
