From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: fix: ifconfig up/down crash
Date: Tue, 24 Nov 2015 16:25:49 -0500 (EST)
Message-ID: <20151124.162549.528006670345277057.davem@davemloft.net>
References: <1448309092-21550-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kdinh@apm.com, patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbbKXVZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 16:25:53 -0500
In-Reply-To: <1448309092-21550-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Mon, 23 Nov 2015 12:04:52 -0800

> Fixing kernel crash when doing ifconfig down and up in a loop,
 ...
> The fix was to reorder napi_enable, napi_disable, request_irq and
> free_irq calls, move register_netdev after dma_coerce_mask_and_coherent.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Tested-by: Khuong Dinh <kdinh@apm.com>

Applied, thanks.
