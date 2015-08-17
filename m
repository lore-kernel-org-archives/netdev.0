From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: ethernet: micrel: fix an error code
Date: Mon, 17 Aug 2015 12:23:37 -0700 (PDT)
Message-ID: <20150817.122337.357015158066421245.davem@davemloft.net>
References: <20150814085459.GC30728@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinod.koul@intel.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbbHQTXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 15:23:38 -0400
In-Reply-To: <20150814085459.GC30728@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 14 Aug 2015 11:54:59 +0300

> The dma_mapping_error() function returns true or false.  We should
> return -ENOMEM if it there is a dma mapping error.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
