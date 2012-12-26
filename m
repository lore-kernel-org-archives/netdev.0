From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IB/rds: Correct ib_api use with
 gs_dma_address/sg_dma_len
Date: Wed, 26 Dec 2012 15:18:05 -0800 (PST)
Message-ID: <20121226.151805.1634688723206807913.davem@davemloft.net>
References: <20121221175857.23716.46975.stgit@phlsvslse11.ph.intel.com>
	<20121221180149.23716.54707.stgit@phlsvslse11.ph.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, linux-rdma@vger.kernel.org,
	roland@kernel.org, rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: mike.marciniszyn@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212Ab2LZXSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 18:18:06 -0500
In-Reply-To: <20121221180149.23716.54707.stgit@phlsvslse11.ph.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Marciniszyn <mike.marciniszyn@intel.com>
Date: Fri, 21 Dec 2012 13:01:49 -0500

> 0b088e00 ("RDS: Use page_remainder_alloc() for recv bufs")
> added uses of sg_dma_len() and sg_dma_address(). This makes
> RDS DOA with the qib driver.
> 
> IB ulps should use ib_sg_dma_len() and ib_sg_dma_address
> respectively since some HCAs overload ib_sg_dma* operations.
> 
> Signed-off-by: Mike Marciniszyn <mike.marciniszyn@intel.com>

Applied.
