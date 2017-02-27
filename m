From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xfrm: provide correct dst in xfrm_neigh_lookup
Date: Sun, 26 Feb 2017 21:35:48 -0500 (EST)
Message-ID: <20170226.213548.1175046698197997781.davem@davemloft.net>
References: <1488038263-12447-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33584 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdB0C5e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 21:57:34 -0500
In-Reply-To: <1488038263-12447-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 25 Feb 2017 17:57:43 +0200

> Fix xfrm_neigh_lookup to provide dst->path to the
> neigh_lookup dst_ops method.
> 
> When skb is provided, the IP address in packet should already
> match the dst->path address family. But for the non-skb case,
> we should consider the last tunnel address as nexthop address.
> 
> Fixes: f894cbf847c9 ("net: Add optional SKB arg to dst_ops->neigh_lookup().")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

This looks good to me.

Steffen, I applied this directly to my tree, I hope you don't mind.
