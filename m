From: David Miller <davem@davemloft.net>
Subject: Re: [patch] dpaa_eth: small leak on error
Date: Fri, 17 Feb 2017 12:19:05 -0500 (EST)
Message-ID: <20170217.121905.367129884701818238.davem@davemloft.net>
References: <20170216095610.GA23242@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: madalin.bucur@nxp.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45740 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934122AbdBQRTH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 12:19:07 -0500
In-Reply-To: <20170216095610.GA23242@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 16 Feb 2017 12:56:10 +0300

> This should be >= instead of > here.  It means that we don't increment
> the free count enough so it becomes off by one.
> 
> Fixes: 9ad1a3749333 ("dpaa_eth: add support for DPAA Ethernet")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> Applies to -net tree.

Applied, thanks Dan.
