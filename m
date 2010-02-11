From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] mlx4: replace the dma_sync_single_range_for_cpu/device API
Date: Thu, 11 Feb 2010 14:31:22 -0800
Message-ID: <adavde35rr9.fsf@roland-alpha.cisco.com>
References: <20100205135626G.fujita.tomonori@lab.ntt.co.jp>
	<20100204.210939.133998827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	rolandd@cisco.com, eli@mellanox.co.il, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:41122 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756799Ab0BKWb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 17:31:27 -0500
In-Reply-To: <20100204.210939.133998827.davem@davemloft.net> (David Miller's
	message of "Thu, 04 Feb 2010 21:09:39 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > > There are only two users of the dma_sync_single_range_for_cpu/device
 > > API in mainline (mlx4 and ssb). The
 > > dma_sync_single_range_for_cpu/device API has never been documented and
 > > the dma_sync_single_for_cpu/device API also support a partial sync.
 > > 
 > > This converts mlx4 to use the dma_sync_single_for_cpu/device API
 > > (preparations for the removal of the dma_sync_single_range_for_cpu/device API).
 > > 
 > > Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
 > 
 > Acked-by: David S. Miller <davem@davemloft.net>

Dave, please go ahead and merge this -- this affects the mlx4 ethernet
driver, so it's your area anyway.
-- 
Roland Dreier  <rolandd@cisco.com>
For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
