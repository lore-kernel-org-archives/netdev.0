From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] flow_dissector: use a 64bit load/store
Date: Tue, 29 Nov 2011 13:23:10 -0500 (EST)
Message-ID: <20111129.132310.605559828840149508.davem@davemloft.net>
References: <4ED3B603.4010702@chelsio.com>
	<20111128.190604.1713178066845491526.davem@davemloft.net>
	<1322548235.2970.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754966Ab1K2SXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 13:23:16 -0500
In-Reply-To: <1322548235.2970.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Nov 2011 07:30:35 +0100

> [PATCH net-next] flow_dissector: use a 64bit load/store
> 
> gcc compiler is smart enough to use a single load/store if we
> memcpy(dptr, sptr, 8) on x86_64, regardless of
> CONFIG_CC_OPTIMIZE_FOR_SIZE
> 
> In IP header, daddr immediately follows saddr, this wont change in the
> future. We only need to make sure our flow_keys (src,dst) fields wont
> break the rule.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
