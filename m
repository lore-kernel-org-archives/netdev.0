From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/5] stmmac: dwmac-socfpga refactor+cleanup
Date: Tue, 03 May 2016 15:22:57 -0400 (EDT)
Message-ID: <20160503.152257.2028216665263623946.davem@davemloft.net>
References: <1462136303-16825-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marex@denx.de, dinguyen@opensource.altera.com,
	peppe.cavallaro@st.com, alexandre.torgue@st.com,
	netdev@vger.kernel.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172AbcECTXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 15:23:00 -0400
In-Reply-To: <1462136303-16825-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Sun,  1 May 2016 22:58:18 +0200

> This patch aims to remove the init/exit callbacks from the dwmac-
> socfpga driver and instead use standard PM callbacks. Doing this
> will also allow us to cleanup the driver.
> 
> Eventually the init/exit callbacks will be deprecated and removed
> from all drivers dwmac-* except for dwmac-generic. Drivers will be
> refactored to use standard PM and remove callbacks.
> 
> This patch set should not change the behavior of the driver itself,
> it only moves code around. The only exception to this is patch
> number 4 which restores the resume callback behavior which was
> changed in the "net: stmmac: socfpga: Remove re-registration of
> reset controller" patch. I belive calling phy_resume() only
> from the resume callback and not probe is the right thing to do.
> 
> Changes from v1:
>  - Rebase on net-next
> 
> One heads-up here:
> The first patch changes the prototype of a couple of
> functions used in Alexandre's "add Ethernet glue logic for
> stm32 chip" patch [1] and will cause build failures for
> dwmac-stm32.c if not fixed up!
> If Alexandre's patch set is applied first I will gladly
> rebase my patch set to account for his driver as well.
> 
> [1] https://patchwork.ozlabs.org/patch/614405/

Series applied, thanks.  stm32 will need to be respun, therefore.
