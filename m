From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 4/5] net/davinci_cpdma: remove unused argument in cpdma_chan_submit()
Date: Thu, 18 Apr 2013 17:21:05 +0530
Message-ID: <516FDE29.10102@ti.com>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-5-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:42121 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752792Ab3DRLvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 07:51:16 -0400
In-Reply-To: <1366235536-15744-5-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/2013 3:22 AM, Sebastian Andrzej Siewior wrote:
> The gfp_mask argument is not used in cpdma_chan_submit() and always set
> to GFP_KERNEL even in atomic sections. This patch drops it since it is
> unused.
>
> Signed-off-by: Sebastian Andrzej Siewior<bigeasy@linutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c          |   10 +++++-----
>   drivers/net/ethernet/ti/davinci_cpdma.c |    2 +-
>   drivers/net/ethernet/ti/davinci_cpdma.h |    2 +-
>   drivers/net/ethernet/ti/davinci_emac.c  |    6 +++---
>   4 files changed, 10 insertions(+), 10 deletions(-)
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
