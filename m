From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] net: qualcomm: rmnet: Fix some existing
 functionality
Date: Tue, 10 Oct 2017 20:11:58 -0700 (PDT)
Message-ID: <20171010.201158.638298226550574884.davem@davemloft.net>
References: <1507681229-27861-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754285AbdJKDMA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 23:12:00 -0400
In-Reply-To: <1507681229-27861-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Tue, 10 Oct 2017 18:20:22 -0600

> This series fixes some of the broken rmnet functionality from the initial
> patchset. Bridge mode is re-written and made useable and the muxed_ep is
> converted to hlist.
> 
> Patches 1-5 are cleanups in preparation for these changes.
> Patch 6 does the hlist conversion.
> Patch 7 has the implementation of the rmnet bridge mode.
> 
> Note that there will be a compilation error when merging net with net-next
> due to the addition of the ext ack argument in
> netdev_master_upper_dev_link / ndo_add_slave.

I don't thnk any of these changes qualify as "fixes".  They don't
fix any bugs at all.

These are cleanups, and the addition of a new feature used for
debugging.

Therefore these should be all targetted at the 'net-next' tree
not 'net'.
