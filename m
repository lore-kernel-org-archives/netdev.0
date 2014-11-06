From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 00/12] amd-xgbe: AMD XGBE driver updates
 2014-11-04
Date: Wed, 05 Nov 2014 22:00:59 -0500 (EST)
Message-ID: <20141105.220059.72751919039494004.davem@davemloft.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaKFDBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 22:01:04 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 4 Nov 2014 16:06:20 -0600

> The following series of patches includes functional updates to the
> driver as well as some trivial changes for function renaming and
> spelling fixes.
> 
> - Move channel and ring structure allocation into the device open path
> - Rename the pre_xmit function to dev_xmit
> - Explicitly use the u32 data type for the device descriptors
> - Use page allocation for the receive buffers
> - Add support for split header/payload receive
> - Add support for per DMA channel interrupts
> - Add support for receive side scaling (RSS)
> - Add support for ethtool receive side scaling commands
> - Fix the spelling of descriptors
> - After a PCS reset, sync the PCS and PHY modes
> - Add dependency on HAS_IOMEM to both the amd-xgbe and amd-xgbe-phy
>   drivers
> 
> This patch series is based on net-next.

Series applied, this series looked really nice.

Thanks.
