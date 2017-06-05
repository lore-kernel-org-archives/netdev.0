From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] amd-xgbe: use PAGE_ALLOC_COSTLY_ORDER in
 xgbe_map_rx_buffer
Date: Sun, 04 Jun 2017 20:01:19 -0400 (EDT)
Message-ID: <20170604.200119.791002119725193988.davem@davemloft.net>
References: <20170602155408.12792-1-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, mhocko@suse.com
To: mhocko@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52686 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751181AbdFEABV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 20:01:21 -0400
In-Reply-To: <20170602155408.12792-1-mhocko@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Hocko <mhocko@kernel.org>
Date: Fri,  2 Jun 2017 17:54:08 +0200

> From: Michal Hocko <mhocko@suse.com>
> 
> xgbe_map_rx_buffer is rather confused about what PAGE_ALLOC_COSTLY_ORDER
> means. It uses PAGE_ALLOC_COSTLY_ORDER-1 assuming that
> PAGE_ALLOC_COSTLY_ORDER is the first costly order which is not the case
> actually because orders larger than that are costly. And even that
> applies only to sleeping allocations which is not the case here. We
> simply do not perform any costly operations like reclaim or compaction
> for those. Simplify the code by dropping the order calculation and use
> PAGE_ALLOC_COSTLY_ORDER directly.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Applied.
