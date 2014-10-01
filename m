From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: mentions skb_gro_postpull_rcsum() in
 inet_gro_receive()
Date: Wed, 01 Oct 2014 13:44:24 -0400 (EDT)
Message-ID: <20141001.134424.581996421154972103.davem@davemloft.net>
References: <1412105832.30721.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140930.161424.679705969149272577.davem@davemloft.net>
	<1412140325.16704.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbaJARo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 13:44:27 -0400
In-Reply-To: <1412140325.16704.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Sep 2014 22:12:05 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Proper CHECKSUM_COMPLETE support needs to adjust skb->csum
> when we remove one header. Its done using skb_gro_postpull_rcsum()
> 
> In the case of IPv4, we know that the adjustment is not really needed,
> because the checksum over IPv4 header is 0. Lets add a comment to
> ease code comprehension and avoid copy/paste errors.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
