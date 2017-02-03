From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix uld_send() for ctrl pkts
Date: Fri, 03 Feb 2017 11:04:57 -0500 (EST)
Message-ID: <20170203.110457.1561222375927349023.davem@davemloft.net>
References: <1486019609-11702-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, arjun@chelsio.com,
        leedom@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37896 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751010AbdBCQFC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 11:05:02 -0500
In-Reply-To: <1486019609-11702-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Thu,  2 Feb 2017 12:43:29 +0530

> From: Arjun V <arjun@chelsio.com>
> 
> Without any uld being loaded, uld_txq_info[] will be NULL. uld_send()
> is also used for sending control work requests(for eg: setting filter)
> that dont require any ulds to be loaded. Hence move uld_txq_info[]
> assignment after ctrl_xmit().
> 
> Also added a NULL check for uld_txq_info[].
> 
> Fixes: 94cdb8bb993a (cxgb4: Add support for dynamic allocation
>        of resources for ULD).
> Signed-off-by: Arjun V <arjun@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied, thanks.
