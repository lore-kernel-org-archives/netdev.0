From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix TCP early demux
Date: Fri, 27 Jul 2012 13:47:13 -0700 (PDT)
Message-ID: <20120727.134713.1437322148321890583.davem@davemloft.net>
References: <1343406220.2626.13092.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab2G0UrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 16:47:13 -0400
In-Reply-To: <1343406220.2626.13092.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Jul 2012 18:23:40 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 92101b3b2e317 (ipv4: Prepare for change of rt->rt_iif encoding.)
> invalidated TCP early demux, because rx_dst_ifindex is not properly
> initialized and checked.
> 
> Also remove the use of inet_iif(skb) in favor or skb->skb_iif
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
