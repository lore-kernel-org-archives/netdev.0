From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] tipc: uninitialized return code in
 tipc_setsockopt()
Date: Wed, 25 Jan 2017 12:41:50 -0500 (EST)
Message-ID: <20170125.124150.1969743532489529180.davem@davemloft.net>
References: <20170124094935.GA19984@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
        netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55700 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751629AbdAYRlw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 12:41:52 -0500
In-Reply-To: <20170124094935.GA19984@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 24 Jan 2017 12:49:35 +0300

> We shuffled some code around and added some new case statements here and
> now "res" isn't initialized on all paths.
> 
> Fixes: 01fd12bb189a ("tipc: make replicast a user selectable option")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
