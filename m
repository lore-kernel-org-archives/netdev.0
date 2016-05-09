From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvtap: segmented packet is consumed
Date: Sun, 08 May 2016 23:44:08 -0400 (EDT)
Message-ID: <20160508.234408.1850254886727916462.davem@davemloft.net>
References: <1462539501.13075.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbcEIDoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 23:44:11 -0400
In-Reply-To: <1462539501.13075.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 May 2016 05:58:21 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> If GSO packet is segmented and its segments are properly queued,
> we call consume_skb() instead of kfree_skb() to be drop monitor
> friendly.
> 
> Fixes: 3e4f8b7873709 ("macvtap: Perform GSO on forwarding path.")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>

Applied, thanks Eric.
