From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] amd-xgbe: AMD XGBE driver updates
 2015-05-12
Date: Fri, 15 May 2015 15:22:40 -0400 (EDT)
Message-ID: <20150515.152240.2196567854221782278.davem@davemloft.net>
References: <20150514164351.10220.89584.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbbEOTWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 15:22:45 -0400
In-Reply-To: <20150514164351.10220.89584.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 14 May 2015 11:43:51 -0500

> The following series of patches includes functional updates and changes
> to the driver.
> 
> - Add additional statistics to be collected and reported
> - Use the netif_* functions for issuing some debug and informational
>   driver messages
> - Rx path SKB allocation cleanup/simplification
> - Remove stand-alone phylib driver and incorporate function into the nic
>   driver
> - Simplify device tree support while maintaining backwards compatibility
> - Fix the flow control negotiation logic to properly configure flow
>   control
> - Remove the checking and setting of the device dma_mask field
> 
> This patch series is based on net-next.
> 
> Changes in v2:
> - Change from using the netif_msg_*/netdev_* combination for issuing
>   messages to the more concise netif_*

Series applied, thanks.

But I hope we don't regret this down the road if this PHY actually is
used in some other application in the future and we need to
reinstantiate the phylib driver again.
