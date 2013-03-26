From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: ethernet: atheros: add CONFIG_PM_SLEEP to
 suspend/resume functions
Date: Tue, 26 Mar 2013 12:47:44 -0400 (EDT)
Message-ID: <20130326.124744.1216273877534310947.davem@davemloft.net>
References: <001b01ce29ef$f09cbf10$d1d63d30$%han@samsung.com>
	<001c01ce29f0$02ccd030$08667090$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934660Ab3CZQrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:47:46 -0400
In-Reply-To: <001c01ce29f0$02ccd030$08667090$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 26 Mar 2013 16:03:25 +0900

> Add CONFIG_PM_SLEEP to suspend/resume functions to fix the following
> build warning when CONFIG_PM_SLEEP is not selected. This is because
> sleep PM callbacks defined by SIMPLE_DEV_PM_OPS are only used when
> the CONFIG_PM_SLEEP is enabled.
> 
> drivers/net/ethernet/atheros/atlx/atl1.c:2861:12: warning: 'atl1_resume' defined but not used [-Wunused-function]
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied to net-next
