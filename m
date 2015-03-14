From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] tipc: some optimizations and
 impovements
Date: Sat, 14 Mar 2015 14:39:02 -0400 (EDT)
Message-ID: <20150314.143902.386608049896474304.davem@davemloft.net>
References: <1426277291-2427-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbbCNSjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 14:39:05 -0400
In-Reply-To: <1426277291-2427-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 13 Mar 2015 16:08:04 -0400

> The commits in this series contain some relatively simple changes that
> lead to better throughput across TIPC connections. We also make changes
> to the implementation of link transmission queueing and priority
> handling, in order to make the code more comprehensible and maintainable.
> 
> v2: Commit #2: Redesigned tipc_msg_validate() to use pskb_may_pull(),
>                as per feedback from David Miller.
>     Commit #3: Some cosmetic changes to tipc_msg_extract(). I tried to
>                replace the unconditional skb_linearize() with calls to
>                pskb_may_pull() at selected locations, but I gave up.
>                First, skb_trim() requires a fully linearized buffer.
>                Second, it doesn't make much sense; the whole buffer
>                will end up linearized, one way or another.

Series applied, thanks Jon.
