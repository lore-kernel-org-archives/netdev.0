From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: fix extra IRQ issue
Date: Sun, 24 Jan 2016 22:16:18 -0800 (PST)
Message-ID: <20160124.221618.1619209434096345332.davem@davemloft.net>
References: <1453421261-4295-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, toanle@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630AbcAYGQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 01:16:19 -0500
In-Reply-To: <1453421261-4295-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Thu, 21 Jan 2016 16:07:41 -0800

> For interrupt controller that doesn't support irq_disable and hardware
> with level interrupt, an extra interrupt may be pending. This patch fixes
> the issue by setting IRQ_DISABLE_UNLAZY flag for the interrupt line,
> as suggested by,
> 
> 'commit e9849777d0e2 ("genirq: Add flag to force mask in
> 		       disable_irq[_nosync]()")'
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Tested-by: Toan Le <toanle@apm.com>

Applied, thanks.
