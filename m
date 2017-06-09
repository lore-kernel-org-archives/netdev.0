From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] cxgb4: handle interrupt raised when FW
 crashes
Date: Fri, 09 Jun 2017 13:12:34 -0400 (EDT)
Message-ID: <20170609.131234.300380070990844661.davem@davemloft.net>
References: <1496986955-11024-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com,
        rahul.lakkireddy@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdFIRMo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 13:12:44 -0400
In-Reply-To: <1496986955-11024-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Fri,  9 Jun 2017 11:12:35 +0530

> From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> 
> Handle TIMER0INT when FW crashes. Check for PCIE_FW[FW_EVAL]
> and if it says "Device FW Crashed", then treat it as fatal.
> Else, non-fatal.
> 
> Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> ---
> v2: Following the reverse chirstmas tree variable ordering

Applied, thank you.
