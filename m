From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2013-11-01
Date: Sat, 02 Nov 2013 02:14:42 -0400 (EDT)
Message-ID: <20131102.021442.1241129501223123137.davem@davemloft.net>
References: <1383292257-4634-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab3KBGOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 02:14:43 -0400
In-Reply-To: <1383292257-4634-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri,  1 Nov 2013 08:50:53 +0100

> This pull request has a trivial merge conflict between git commit
> e7d8f6c ("xfrm: Add refcount handling to queued policies") and
> git commit 4d53eff ("xfrm: Don't queue retransmitted packets if
> the original is still on the host"). It can be solved as it is
> currently done in linux-next.
> 
> 1) Use vmalloc_node for ipcomp percpu scratches to get proper
>    NUMA affinity, from Eric Dumazet
> 
> 2) Avoid to retransmit packets if the original packet is
>    still in the xfrm hold queue.
> 
> 3) Remove unused padlen field from struct esp_data.
>    From Mathias Krause.
> 
> 4) Remove struct esp_data because now it consists of a single
>    pointer. From Mathias Krause.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot.
