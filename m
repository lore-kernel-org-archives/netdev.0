From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix a possible use after free
Date: Wed, 24 Aug 2011 17:50:54 -0700 (PDT)
Message-ID: <20110824.175054.2217340464184681338.davem@davemloft.net>
References: <1314165425.4478.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au,
	shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab1HYAvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 20:51:02 -0400
In-Reply-To: <1314165425.4478.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Aug 2011 07:57:05 +0200

> br_multicast_ipv6_rcv() can call pskb_trim_rcsum() and therefore skb
> head can be reallocated.
> 
> Cache icmp6_type field instead of dereferencing twice the struct
> icmp6hdr pointer.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
