From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qed: Correct MSI-x for storage
Date: Thu, 06 Apr 2017 13:35:48 -0700 (PDT)
Message-ID: <20170406.133548.1690250143569260286.davem@davemloft.net>
References: <1491416411-27750-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37928 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751879AbdDFUft (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 16:35:49 -0400
In-Reply-To: <1491416411-27750-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Wed, 5 Apr 2017 21:20:11 +0300

> When qedr is enabled, qed would try dividing the msi-x vectors between
> L2 and RoCE, starting with L2 and providing it with sufficient vectors
> for its queues.
> 
> Problem is qed would also do that for storage partitions, and as those
> don't need queues it would lead qed to award those partitions with 0
> msi-x vectors, causing them to believe theye're using INTa and
> preventing them from operating.
> 
> Fixes: 51ff17251c9c ("qed: Add support for RoCE hw init")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied, thanks.
