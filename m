From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: move rx and tx hash functions to
 net/core/flow_dissector.c
Date: Mon, 21 Jan 2013 15:46:16 -0500 (EST)
Message-ID: <20130121.154616.863812714079911749.davem@davemloft.net>
References: <1358764764-3533-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	bhutchings@solarflare.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab3AUUqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 15:46:18 -0500
In-Reply-To: <1358764764-3533-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 21 Jan 2013 18:39:24 +0800

> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> __skb_tx_hash() and __skb_get_rxhash() are all for calculating hash
> value based by some fields in skb, mostly used for selecting queues
> by device drivers.
> 
> Meanwhile, net/core/dev.c is bloating.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
