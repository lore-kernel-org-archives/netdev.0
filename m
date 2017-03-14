From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] qed: Fixes series
Date: Tue, 14 Mar 2017 11:38:17 -0700 (PDT)
Message-ID: <20170314.113817.601129094826553811.davem@davemloft.net>
References: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750820AbdCNSiT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 14:38:19 -0400
In-Reply-To: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Tue, 14 Mar 2017 15:25:57 +0200

> This address several different issues in qed.
> The more significant portions:
> 
> Patch #1 would cause timeout when qedr utilizes the highest
> CIDs availble for it [or when future qede adapters would utilize
> queues in some constellations].
> 
> Patch #4 fixes a leak of mapped addresses; When iommu is enabled,
> offloaded storage protocols might eventually run out of resources
> and fail to map additional buffers.
> 
> Patches #6,#7 were missing in the initial iSCSI infrastructure
> submissions, and would hamper qedi's stability when it reaches
> out-of-order scenarios.

Series applied, thank you.
