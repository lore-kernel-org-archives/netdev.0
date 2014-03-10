From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: timestamp SYN+DATA messages
Date: Mon, 10 Mar 2014 16:17:13 -0400 (EDT)
Message-ID: <20140310.161713.1127783605617059649.davem@davemloft.net>
References: <1394411762.20149.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbaCJURO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:17:14 -0400
In-Reply-To: <1394411762.20149.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 09 Mar 2014 17:36:02 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> All skb in socket write queue should be properly timestamped.
> 
> In case of FastOpen, we special case the SYN+DATA 'message' as we
> queue in socket wrote queue the two fallback skbs: 
> 
> 1) SYN message by itself.
> 2) DATA segment by itself.
> 
> We should make sure these skbs have proper timestamps.
> 
> Add a WARN_ON_ONCE() to eventually catch future violations.
> 
> Fixes: 740b0f1841f6 ("tcp: switch rtt estimations to usec resolution")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
