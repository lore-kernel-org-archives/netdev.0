From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] amd-xgbe: AMD XGBE driver update
 2014-07-25
Date: Mon, 28 Jul 2014 17:33:59 -0700 (PDT)
Message-ID: <20140728.173359.1659401063111761702.davem@davemloft.net>
References: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbaG2AeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 20:34:00 -0400
In-Reply-To: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 25 Jul 2014 16:10:52 -0500

> This patch series is dependent on the following patch that was
> applied to the net tree and needs to be applied to the net-next
> tree:
>   332cfc823d18 - amd-xgbe: Fix error return code in xgbe_probe()
> 
> The following series of patches includes fixes and new support in the
> driver.
> 
> - Device bindings documentation update
> - Hardware timestamp support
> - 2.5GbE support changes
> - Fifo sizes based on active queues/rings
> - Phylib driver updates for:
>   - Rate change completion check
>   - KR training initiation
>   - Auto-negotiation results
> - Traffic class support, including DCB support
> 
> This patch series is based on net-next.

I was going to apply this, but I couldn't let those function tracing debug
giblets into the tree.

Please remove all of that DBGPR(...., __func__) stuff.

We have a generic function tracer which can be used to trace any path
of execution in the kernel.
