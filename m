From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/4] net/ncsi: More bug fixes
Date: Thu, 20 Oct 2016 11:23:25 -0400 (EDT)
Message-ID: <20161020.112325.907295254918060127.davem@davemloft.net>
References: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joel@jms.id.au
To: gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965150AbcJTPX1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 11:23:27 -0400
In-Reply-To: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Date: Thu, 20 Oct 2016 11:45:48 +1100

> This series fixes 2 issues that were found during NCSI's availability
> testing on BCM5718 and improves HNCDSC AEN handler:
> 
>    * PATCH[1] refactors the code so that minimal code change is put
>      to PATCH[2].
>    * PATCH[2] fixes the NCSI channel's stale link state before doing
>      failover.
>    * PATCH[3] chooses the hot channel, which was ever chosen as active
>      channel, when the available channels are all in link-down state.
>    * PATCH[4] improves Host Network Controller Driver Status Change
>      (HNCDSC) AEN handler
> 
> Changelog
> =========
> v2:
>    * Merged PATCH[v1 1/2] to PATCH[v2 1].
>    * Avoid if/else statements in ncsi_suspend_channel() as Joel suggested.
>    * Added comments to explain why we need retrieve last link states in
>      ncsi_suspend_channel().

Series applied, thanks.
