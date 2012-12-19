From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] solos-pci: ensure all TX packets are aligned to 4
 bytes
Date: Wed, 19 Dec 2012 14:54:19 -0800 (PST)
Message-ID: <20121219.145419.167479039508052203.davem@davemloft.net>
References: <1355950881-31550-1-git-send-email-dwmw2@infradead.org>
	<1355950881-31550-4-git-send-email-dwmw2@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David.Woodhouse@intel.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab2LSWyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 17:54:19 -0500
In-Reply-To: <1355950881-31550-4-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 19 Dec 2012 21:01:21 +0000

> From: David Woodhouse <David.Woodhouse@intel.com>
> 
> The FPGA can't handled unaligned DMA (yet). So copy into an aligned buffer,
> if skb->data isn't suitably aligned.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied.
