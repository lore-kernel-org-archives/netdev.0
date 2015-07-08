From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Fix DMA API debug warning
Date: Wed, 08 Jul 2015 15:58:12 -0700 (PDT)
Message-ID: <20150708.155812.592764115489966730.davem@davemloft.net>
References: <20150706165737.2337.95787.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kim.phillips@arm.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbbGHW6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 18:58:13 -0400
In-Reply-To: <20150706165737.2337.95787.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Mon, 6 Jul 2015 11:57:37 -0500

> When running a kernel configured with CONFIG_DMA_API_DEBUG=y a warning
> is issued:
>   DMA-API: device driver tries to sync DMA memory it has not allocated
> 
> This warning is the result of mapping the full range of the Rx buffer
> pages allocated and then performing a dma_sync_single_for_cpu against
> a calculated DMA address. The proper thing to do is to use the
> dma_sync_single_range_for_cpu with a base DMA address and an offset.
> 
> Reported-by: Kim Phillips <kim.phillips@arm.com>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks Tom.
