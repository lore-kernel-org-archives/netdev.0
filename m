From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: add bond_tx_drop() helper
Date: Fri, 31 Oct 2014 16:09:22 -0400 (EDT)
Message-ID: <20141031.160922.1328924214385970387.davem@davemloft.net>
References: <1414781274.27538.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, maheshb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbaJaUJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 16:09:26 -0400
In-Reply-To: <1414781274.27538.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 31 Oct 2014 11:47:54 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Because bonding stats are usually sum of slave stats, it was
> not easy to account for tx drops at bonding layer.
> 
> We can use dev->tx_dropped for this, as this counter is later
> added to the device stats (in dev_get_stats())
> 
> This extends the idea we had in commit ee6377147409a ("bonding: Simplify
> the xmit function for modes that use xmit_hash") for bond_3ad_xor_xmit()
> to other bonding modes.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>

Applied, thanks Eric.
