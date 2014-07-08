From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] amd-xgbe: AMD 10Gb Ethernet driver updates
Date: Mon, 07 Jul 2014 21:38:36 -0700 (PDT)
Message-ID: <20140707.213836.844443830383552014.davem@davemloft.net>
References: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48891 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaGHEih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 00:38:37 -0400
In-Reply-To: <20140702180422.14996.88116.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 2 Jul 2014 13:04:22 -0500

> The following series fixes some bugs and provides new/changed support
> in the driver.
> 
> - Fix a debugfs backward compatibility issue introduced by a previous patch
> - Write to the interrupt enablement register, not the status register when
>   setting MTL interrupts
> - Call netif_napi_del whenever the ndo_stop operation is called (to match
>   the call to netif_napi_add on ndo_open)
> - Peformance enhancements:
>   - Adjusted default coalescing settings
>   - AXI DMA changes (burst length size and cache settings)
>   - ioread/iowrite reduction during interrupt
>   - Napi poll updates
> - AXI DMA settings based on device tree property to account for a change in
>   the ARM64 default cache operations assignment
> 
> This patch series is based on net-next.

Series applied, thanks.
