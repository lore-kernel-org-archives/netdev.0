From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] cxgb4: ptp_clock_register() returns error
 pointers
Date: Fri, 14 Jul 2017 08:19:03 -0700 (PDT)
Message-ID: <20170714.081903.1808205304295203754.davem@davemloft.net>
References: <1499951210-6283-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, atul.gupta@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        dan.carpenter@oracle.com, richardcochran@gmail.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36266 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754504AbdGNPTF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 11:19:05 -0400
In-Reply-To: <1499951210-6283-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Thu, 13 Jul 2017 18:36:50 +0530

> Check ptp_clock_register() return not only for NULL but
> also for error pointers, and also nullify adapter->ptp_clock
> if ptp_clock_register() fails.
> 
> Fixes: 9c33e4208bce ("cxgb4: Add PTP Hardware Clock (PHC) support")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> ---
> v2: nullifying adapter->ptp_clock if ptp_clock_register() fails.

Applied.
