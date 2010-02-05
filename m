From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: replace the dma_sync_single_range_for_cpu/device
 API
Date: Thu, 04 Feb 2010 21:09:39 -0800 (PST)
Message-ID: <20100204.210939.133998827.davem@davemloft.net>
References: <20100205135626G.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rolandd@cisco.com, eli@mellanox.co.il,
	linux-kernel@vger.kernel.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36845
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750992Ab0BEFJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 00:09:26 -0500
In-Reply-To: <20100205135626G.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 5 Feb 2010 13:57:42 +0900

> There are only two users of the dma_sync_single_range_for_cpu/device
> API in mainline (mlx4 and ssb). The
> dma_sync_single_range_for_cpu/device API has never been documented and
> the dma_sync_single_for_cpu/device API also support a partial sync.
> 
> This converts mlx4 to use the dma_sync_single_for_cpu/device API
> (preparations for the removal of the dma_sync_single_range_for_cpu/device API).
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Acked-by: David S. Miller <davem@davemloft.net>
