From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: restore tx timestamping for accelerated vlans
Date: Wed, 30 Sep 2009 16:43:03 -0700 (PDT)
Message-ID: <20090930.164303.185548394.davem@davemloft.net>
References: <4AC20441.8040004@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54888
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754771AbZI3Xmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 19:42:43 -0400
In-Reply-To: <4AC20441.8040004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Sep 2009 14:57:37 +0200

> Since commit 9b22ea560957de1484e6b3e8538f7eef202e3596
> ( net: fix packet socket delivery in rx irq handler )
> 
> We lost rx timestamping of packets received on accelerated vlans.
> 
> Effect is that tcpdump on real dev can show strange timings, since it gets rx timestamps
> too late (ie at skb dequeueing time, not at skb queueing time)
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, and queued up for -stable, thanks!
