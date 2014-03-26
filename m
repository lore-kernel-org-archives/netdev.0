From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: Rename skb->rxhash to skb->hash
Date: Wed, 26 Mar 2014 15:58:41 -0400 (EDT)
Message-ID: <20140326.155841.2209326483495380149.davem@davemloft.net>
References: <alpine.DEB.2.02.1403201659350.6989@tomh.mtv.corp.google.com>
	<1395698805.12610.78.camel@edumazet-glaptop2.roam.corp.google.com>
	<1395700487.12610.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org, maheshb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369AbaCZT6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:58:44 -0400
In-Reply-To: <1395700487.12610.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Mar 2014 15:34:47 -0700

> From: Tom Herbert <therbert@google.com>
> 
> The packet hash can be considered a property of the packet, not just
> on RX path.
> 
> This patch changes name of rxhash and l4_rxhash skbuff fields to be
> hash and l4_hash respectively. This includes changing uses of the
> field in the code which don't call the access functions.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This looks fine to me, applied, thanks Eric.
