From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: checking for NULL instead of IS_ERR()
Date: Fri, 20 Oct 2017 08:34:30 +0100 (WEST)
Message-ID: <20171020.083430.260489693883420009.davem@davemloft.net>
References: <20171018074825.2bi42vewrqhdbte3@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
        netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33992 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751783AbdJTHee (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 03:34:34 -0400
In-Reply-To: <20171018074825.2bi42vewrqhdbte3@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 18 Oct 2017 10:48:25 +0300

> The tipc_alloc_conn() function never returns NULL, it returns error
> pointers, so I have fixed the check.
> 
> Fixes: 14c04493cb77 ("tipc: add ability to order and receive topology events in driver")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
