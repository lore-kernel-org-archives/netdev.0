From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] gro: should aggregate frames without DF
Date: Fri, 31 May 2013 17:15:00 -0700 (PDT)
Message-ID: <20130531.171500.2100142825483179922.davem@davemloft.net>
References: <1370019752.5109.108.camel@edumazet-glaptop>
	<1370030944.2703.17.camel@bwh-desktop.uk.level5networks.com>
	<1370035090.5109.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	hkchu@google.com, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715Ab3FAAPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:15:01 -0400
In-Reply-To: <1370035090.5109.113.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 31 May 2013 14:18:10 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> GRO on IPv4 doesn't aggregate frames if they don't have DF bit set.
> 
> Some servers use IP_MTU_DISCOVER/IP_PMTUDISC_PROBE, so linux receivers
> are unable to aggregate this kind of traffic.
> 
> The right thing to do is to allow aggregation as long as the DF bit has
> same value on all segments.
> 
> bnx2x LRO does this correctly.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
