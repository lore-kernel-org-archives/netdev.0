From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp: provide skb->hash to synack packets
Date: Thu, 17 Sep 2015 21:01:13 -0700 (PDT)
Message-ID: <20150917.210113.705380890765888132.davem@davemloft.net>
References: <1442355860.4116.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, maheshb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbbIREBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 00:01:16 -0400
In-Reply-To: <1442355860.4116.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Sep 2015 15:24:20 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit b73c3d0e4f0e ("net: Save TX flow hash in sock and set in skbuf
> on xmit"), Tom provided a l4 hash to most outgoing TCP packets.
> 
> We'd like to provide one as well for SYNACK packets, so that all packets
> of a given flow share same txhash, to later enable bonding driver to
> also use skb->hash to perform slave selection.
> 
> Note that a SYNACK retransmit shuffles the tx hash, as Tom did
> in commit 265f94ff54d62 ("net: Recompute sk_txhash on negative routing
> advice") for established sockets.
> 
> This has nice effect making TCP flows resilient to some kind of black
> holes, even at connection establish phase.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
