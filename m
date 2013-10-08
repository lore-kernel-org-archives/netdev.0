From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 0/2] net/mlx4_en: Fix pages never dma unmapped
 on rx
Date: Tue, 08 Oct 2013 16:10:41 -0400 (EDT)
Message-ID: <20131008.161041.1806361844804673553.davem@davemloft.net>
References: <1381145893-20930-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	eugenia@mellanox.com, edumazet@google.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488Ab3JHUKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:10:42 -0400
In-Reply-To: <1381145893-20930-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon,  7 Oct 2013 13:38:11 +0200

> This patchset fixes a bug introduced by commit 51151a16 (mlx4: allow order-0
> memory allocations in RX path). Where dma_unmap_page wasn't called.
> 
> Changes from V0:
> - Added "Rename name of mlx4_en_rx_alloc members". Old names were confusing.
> - Last frag in page calculation was wrong. Since all frags in page are of the
>   same size, need to add this frag_stride to end of frag offset, and not the
>   size of next frag in skb.

Series applied, thanks.
