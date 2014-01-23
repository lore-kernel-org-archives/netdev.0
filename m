From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: Remove unnecessary vlan_put_tag in
 br_handle_vlan
Date: Wed, 22 Jan 2014 21:30:05 -0800 (PST)
Message-ID: <20140122.213005.510576128360790291.davem@davemloft.net>
References: <1390350577-4122-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, vyasevic@redhat.com,
	netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbaAWFaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 00:30:06 -0500
In-Reply-To: <1390350577-4122-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Wed, 22 Jan 2014 09:29:37 +0900

> br_handle_vlan() pushes HW accelerated vlan tag into skbuff when outgoing
> port is the bridge device.
> This is unnecessary because __netif_receive_skb_core() can handle skbs
> with HW accelerated vlan tag. In current implementation,
> __netif_receive_skb_core() needs to extract the vlan tag embedded in skb
> data. This could cause low network performance especially when receiving
> frames at a high frame rate on the bridge device.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied.
