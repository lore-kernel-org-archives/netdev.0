From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: fix a race in irlan_eth_xmit()
Date: Thu, 19 Aug 2010 00:42:02 -0700 (PDT)
Message-ID: <20100819.004202.84378290.davem@davemloft.net>
References: <1282127083.2194.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39990
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751595Ab0HSHlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:41:42 -0400
In-Reply-To: <1282127083.2194.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Aug 2010 12:24:43 +0200

> After skb is queued, its illegal to dereference it.
> 
> Cache skb->len into a temporary variable.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
