From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 14:01:21 -0700 (PDT)
Message-ID: <20120620.140121.1603737472432326278.davem@davemloft.net>
References: <1340171940.4604.799.camel@edumazet-glaptop>
	<1340215664.2576.12.camel@bwh-desktop.uk.solarflarecom.com>
	<1340217604.4604.1569.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960Ab2FTVBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 17:01:22 -0400
In-Reply-To: <1340217604.4604.1569.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 20:40:04 +0200

> If someone wants to tune its linux router, he probably already disables
> GRO because of various issues with too big packets.
> 
> GRO adds a significant cost to forwarding path.

No, Ben is right Eric.  GRO decreases the costs, because it means we
only need to make one forwarding/netfilter/classification decision for
N packets instead of 1.
