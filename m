From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Fix stacked vlan offload features computation
Date: Wed, 24 Dec 2014 00:09:17 -0500 (EST)
Message-ID: <20141224.000917.2245589354389943898.davem@davemloft.net>
References: <1419242654-4824-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbaLXFJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 00:09:19 -0500
In-Reply-To: <1419242654-4824-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Mon, 22 Dec 2014 19:04:14 +0900

> When vlan tags are stacked, it is very likely that the outer tag is stored
> in skb->vlan_tci and skb->protocol shows the inner tag's vlan_proto.
> Currently netif_skb_features() first looks at skb->protocol even if there
> is the outer tag in vlan_tci, thus it incorrectly retrieves the protocol
> encapsulated by the inner vlan instead of the inner vlan protocol.
> This allows GSO packets to be passed to HW and they end up being
> corrupted.
> 
> Fixes: 58e998c6d239 ("offloading: Force software GSO for multiple vlan tags.")
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied and queued up for -stable, thanks.
