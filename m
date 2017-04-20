From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qede: allocate enough data for
 ->arfs_fltr_bmap
Date: Thu, 20 Apr 2017 16:25:47 -0400 (EDT)
Message-ID: <20170420.162547.1676158647736779786.davem@davemloft.net>
References: <20170419095432.GA4266@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Chopra@mwanda, Manish.Chopra@cavium.com,
        Ariel.Elior@cavium.com, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49072 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033680AbdDTUZu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 16:25:50 -0400
In-Reply-To: <20170419095432.GA4266@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 19 Apr 2017 12:54:33 +0300

> We've got the number of longs, yes, but we should multiply by
> sizeof(long) to get the number of bytes needed.
> 
> Fixes: e4917d46a653 ("qede: Add aRFS support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
