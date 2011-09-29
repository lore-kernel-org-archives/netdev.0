From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RDSRDMA: Fix cleanup of rds_iw_mr_pool
Date: Thu, 29 Sep 2011 14:57:53 -0400 (EDT)
Message-ID: <20110929.145753.1706155272362887387.davem@davemloft.net>
References: <20110929175841.17682.27846.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: jonathan@ogc.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284Ab1I2S6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 14:58:00 -0400
In-Reply-To: <20110929175841.17682.27846.stgit@build.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Lallinger <jonathan@ogc.us>
Date: Thu, 29 Sep 2011 12:58:41 -0500

> In the rds_iw_mr_pool struct the free_pinned field keeps track of
> memory pinned by free MRs. While this field is incremented properly
> upon allocation, it is never decremented upon unmapping. This would
> cause the rds_rdma module to crash the kernel upon unloading, by
> triggering the BUG_ON in the rds_iw_destroy_mr_pool function.
> 
> This change keeps track of the MRs that become unpinned, so that
> free_pinned can be decremented appropriately.
> 
> Signed-off-by: Jonathan Lallinger <jonathan@ogc.us>
> Signed-off-by: Steve Wise <swise@ogc.us>

Applied.
