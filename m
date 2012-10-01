From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] tcp: gro: add checksuming helpers
Date: Mon, 01 Oct 2012 17:03:52 -0400 (EDT)
Message-ID: <20121001.170352.1495231606129041662.davem@davemloft.net>
References: <1348748093.5093.1171.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab2JAVDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 17:03:54 -0400
In-Reply-To: <1348748093.5093.1171.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Sep 2012 14:14:53 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> skb with CHECKSUM_NONE cant currently be handled by GRO, and
> we notice this deep in GRO stack in tcp[46]_gro_receive()
> 
> But there are cases where GRO can be a benefit, even with a lack
> of checksums.
> 
> This preliminary work is needed to add GRO support
> to tunnels.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
