From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/5] net/davinci_cpdma: don't check for jiffies with interrupts
Date: Thu, 18 Apr 2013 17:19:54 +0530
Message-ID: <516FDDE2.6080500@ti.com>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-2-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:45272 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967170Ab3DRLuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 07:50:07 -0400
In-Reply-To: <1366235536-15744-2-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/2013 3:22 AM, Sebastian Andrzej Siewior wrote:
> __cpdma_chan_process() holds the lock with interrupts off (and its
> caller as well), same goes for cpdma_ctlr_start(). With interrupts off,
> jiffies will not make any progress and if the wait condition never gets
> true we wait for ever.
> Tgis patch adds a a simple udelay and counting down attempt.
>
> Signed-off-by: Sebastian Andrzej Siewior<bigeasy@linutronix.de>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
