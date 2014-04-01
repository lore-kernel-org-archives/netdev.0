From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] net: sxgbe: make "core_ops" static
Date: Tue, 01 Apr 2014 16:27:44 -0400 (EDT)
Message-ID: <20140401.162744.185225542622478942.davem@davemloft.net>
References: <20140401133918.GA11087@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbaDAU1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:27:46 -0400
In-Reply-To: <20140401133918.GA11087@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 1 Apr 2014 16:39:18 +0300

> The "core_ops" variable isn't referenced outside this file and Sparse
> complains about it:
> 
> 	drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c:239:29: warning:
> 	symbol 'core_ops' was not declared. Should it be static?
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
