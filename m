From: David Miller <davem@davemloft.net>
Subject: Re: [PATCBN net-next] mlx4_en: fix skb truesize underestimation
Date: Wed, 19 Oct 2011 19:53:41 -0400 (EDT)
Message-ID: <20111019.195341.1872717723240004710.davem@davemloft.net>
References: <1318932782.2657.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.co.il
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010Ab1JSXxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 19:53:51 -0400
In-Reply-To: <1318932782.2657.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Oct 2011 12:13:02 +0200

> skb->truesize must account for allocated memory, not the used part of
> it. Doing this work is important to avoid unexpected OOM situations.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Eric please respin this against current net-next, it doesn't apply
after the mlx4 series I applied today.

Thanks!
