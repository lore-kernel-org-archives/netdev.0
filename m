From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ftgmac100/ftmac100: dont pull too much
 data
Date: Wed, 18 Jul 2012 09:42:04 -0700 (PDT)
Message-ID: <20120718.094204.295861832531987796.davem@davemloft.net>
References: <1342102778.3265.8272.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ratbert@faraday-tech.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199Ab2GRQmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:42:05 -0400
In-Reply-To: <1342102778.3265.8272.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Jul 2012 16:19:38 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Drivers should pull only ethernet header from page frag
> to skb->head.
> 
> Pulling 64 bytes is too much for TCP (without options) on IPv4.
> 
> However, it makes sense to pull all the frame if it fits the
> 128 bytes bloc allocated for skb->head, to free one page per
> small incoming frame.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
