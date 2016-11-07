From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 0/7] stmmac: dwmac-sti refactor+cleanup
Date: Sun, 06 Nov 2016 22:00:33 -0500 (EST)
Message-ID: <20161106.220033.1499160366690845326.davem@davemloft.net>
References: <20161104175411.12943-1-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48580 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751646AbcKGDBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 22:01:24 -0500
In-Reply-To: <20161104175411.12943-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Fri,  4 Nov 2016 18:54:04 +0100

> This patch set aims to remove the init/exit callbacks from the 
> dwmac-sti driver and instead use standard PM callbacks. Doing this
> will also allow us to cleanup the driver.
> 
> Eventually the init/exit callbacks will be deprecated and removed
> from all drivers dwmac-* except for dwmac-generic. Drivers will be
> refactored to use standard PM and remove callbacks.
> 
> Changes since v2:
>  - add missing static to sti_dwmac_pm_ops
>  - s/sti_dwmac_set_phy_mode/sti_dwmac_set_mode
>  - acked/tested by Giuseppe

Series applied, thanks.
