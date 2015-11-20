From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tipc: some cleanups and improvements
Date: Fri, 20 Nov 2015 14:06:57 -0500 (EST)
Message-ID: <20151120.140657.2023428662451748232.davem@davemloft.net>
References: <1447961447-13025-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbbKTTG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 14:06:59 -0500
In-Reply-To: <1447961447-13025-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 19 Nov 2015 14:30:38 -0500

> This series mostly contains cleanups and cosmetic code changes.
> The only real functional change is in #4 and #5, where we change the
> locking structure for nodes and links in order to permit full
> concurrency between links working in parallel on different interfaces.
> Since the groundwork for this has been done in previous commit series,
> this change constitutes only the final, small step to achieve that goal.

Series applied, thanks.

Generally speaking, rwlock usage really never buys you anything
significant.  Therefore in the long run I think a single spinlock plus
RCU is going to be much better for per-node locking in TIPC.
