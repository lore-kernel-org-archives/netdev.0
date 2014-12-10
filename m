From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] amd-xgbe: Use disable_irq_nosync when in IRQ
 context
Date: Tue, 09 Dec 2014 21:48:23 -0500 (EST)
Message-ID: <20141209.214823.1842322409407119669.davem@davemloft.net>
References: <20141209205408.26097.70441.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674AbaLJCs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 21:48:26 -0500
In-Reply-To: <20141209205408.26097.70441.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 9 Dec 2014 14:54:08 -0600

> The disable_irq_nosync function, not the disable_irq function, must be
> used to disable the DMA channel interrupt from within the interrupt
> service routine. Change the disable_irq call to disable_irq_nosync.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks Tom.
