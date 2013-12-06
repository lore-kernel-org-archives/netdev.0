From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: clear local_df when passing skb between namespaces
Date: Thu, 05 Dec 2013 23:43:20 -0500 (EST)
Message-ID: <20131205.234320.1507003892401539154.davem@davemloft.net>
References: <2134F8430051B64F815C691A62D9831816F6A4@XCH-BLV-504.nw.nos.boeing.com>
	<20131205201856.GC21745@order.stressinduktion.org>
	<20131205222919.GD21745@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Fred.L.Templin@boeing.com, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab3LFEnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 23:43:21 -0500
In-Reply-To: <20131205222919.GD21745@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 5 Dec 2013 23:29:19 +0100

> We must clear local_df when passing the skb between namespaces as the
> packet is not local to the new namespace any more and thus may not get
> fragmented by local rules. Fred Templin noticed that other namespaces
> do fragment IPv6 packets while forwarding. Instead they should have send
> back a PTB.
> 
> The same problem should be present when forwarding DF-IPv4 packets
> between namespaces.
> 
> Reported-by: Templin, Fred L <Fred.L.Templin@boeing.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks Hannes.
