From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] smc: some potential use after free bugs
Date: Mon, 30 Jan 2017 16:38:28 -0500 (EST)
Message-ID: <20170130.163828.1269554309604072824.davem@davemloft.net>
References: <20170130095504.7940-1-ubraun@linux.vnet.ibm.com>
        <20170130095504.7940-2-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        dan.carpenter@oracle.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754386AbdA3Vim (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 16:38:42 -0500
In-Reply-To: <20170130095504.7940-2-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Mon, 30 Jan 2017 10:55:04 +0100

> From: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Say we got really unlucky and these failed on the last iteration, then
> it could lead to a use after free bug.
> 
> Fixes: cd6851f30386 ("smc: remote memory buffers (RMBs)")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>

Applied, thank you.
