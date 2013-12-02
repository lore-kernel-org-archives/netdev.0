From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers: net: cpsw: fix dt probe for one port
 ethernet
Date: Mon, 02 Dec 2013 16:56:15 -0500 (EST)
Message-ID: <20131202.165615.1138261979635261767.davem@davemloft.net>
References: <1385969019-12880-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688Ab3LBV4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 16:56:17 -0500
In-Reply-To: <1385969019-12880-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Mon, 2 Dec 2013 12:53:39 +0530

> When only one port of the two port is pinned out, then dt probe is failing
> because second port phy is not found. fixing this by checking the number of
> slaves and breaking the loop.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Of course, this patch assumes that slaves are pinned out in order.

But, no matter, this makes more configurations work than before so
it's a good patch.

Applied, thanks.
