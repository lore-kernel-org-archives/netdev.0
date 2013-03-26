From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: ethernet: wiznet: add CONFIG_PM_SLEEP to
 suspend/resume functions
Date: Tue, 26 Mar 2013 12:47:37 -0400 (EDT)
Message-ID: <20130326.124737.402458923814889687.davem@davemloft.net>
References: <001b01ce29ef$f09cbf10$d1d63d30$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41061 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756373Ab3CZQrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:47:40 -0400
In-Reply-To: <001b01ce29ef$f09cbf10$d1d63d30$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 26 Mar 2013 16:02:55 +0900

> Add CONFIG_PM_SLEEP to suspend/resume functions to fix the following
> build warning when CONFIG_PM_SLEEP is not selected. This is because
> sleep PM callbacks defined by SIMPLE_DEV_PM_OPS are only used when
> the CONFIG_PM_SLEEP is enabled.
> 
> drivers/net/ethernet/wiznet/w5100.c:758:12: warning: 'w5100_suspend' defined but not used [-Wunused-function]
> drivers/net/ethernet/wiznet/w5100.c:773:12: warning: 'w5100_resume' defined but not used [-Wunused-function]
> drivers/net/ethernet/wiznet/w5300.c:670:12: warning: 'w5300_suspend' defined but not used [-Wunused-function]
> drivers/net/ethernet/wiznet/w5300.c:685:12: warning: 'w5300_resume' defined but not used [-Wunused-function]
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied to net-next
