From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: call consume_skb() in frag/reassembly
Date: Wed, 25 Apr 2012 20:40:23 -0400 (EDT)
Message-ID: <20120425.204023.2208260917073200324.davem@davemloft.net>
References: <1335298679.5205.173.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932686Ab2DZAkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 20:40:25 -0400
In-Reply-To: <1335298679.5205.173.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Apr 2012 22:17:59 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Some kfree_skb() calls should be replaced by consume_skb() to avoid
> drop_monitor/dropwatch false positives.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
