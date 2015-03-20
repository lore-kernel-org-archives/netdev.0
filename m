From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/9] amd-xgbe: AMD XGBE driver updates
 2015-03-19
Date: Fri, 20 Mar 2015 16:34:25 -0400 (EDT)
Message-ID: <20150320.163425.84256359457323221.davem@davemloft.net>
References: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbbCTUe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:34:26 -0400
In-Reply-To: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 20 Mar 2015 11:49:36 -0500

> The following series of patches includes functional updates and changes
> to the driver.
> 
> - Use the phydev->advertising field instead of the phydev->supported
>   field when configuring for auto-negotiation, etc.
> - Use the phy_driver flags field for setting the transceiver type
>   instead of hardcoding it in the ethtool support.
> - Provide an auto-negotiation timeout check
> - Clarify the Tx/Rx queue information messages
> - Use the new DMA memory barrier operations
> - Set the device DMA mask based on what the hardware reports
> - Remove the software implementation of Tx coalescing
> - Fix the reporting of the Rx coalescing value
> - Use napi_alloc_skb when allocating an SKB in softirq
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
