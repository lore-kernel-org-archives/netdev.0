From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: macb: ensure ordering write to re-enable
 RX smoothly
Date: Tue, 29 Nov 2016 20:34:12 -0500 (EST)
Message-ID: <20161129.203412.2165914496634643324.davem@davemloft.net>
References: <1480341300-17384-1-git-send-email-zumeng.chen@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: zumeng.chen@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752739AbcK3BeP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 20:34:15 -0500
In-Reply-To: <1480341300-17384-1-git-send-email-zumeng.chen@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zumeng Chen <zumeng.chen@windriver.com>
Date: Mon, 28 Nov 2016 21:55:00 +0800

> When a hardware issue happened as described by inline comments, the register
> write pattern looks like the following:
> 
> <write ~MACB_BIT(RE)>
> + wmb();
> <write MACB_BIT(RE)>
> 
> There might be a memory barrier between these two write operations, so add wmb
> to ensure an flip from 0 to 1 for NCR.
> 
> Signed-off-by: Zumeng Chen <zumeng.chen@windriver.com>
> ---
> 
> V2 changes:
> 
> Add the same wmb for at91ether as well based on reviewer's suggestion.

Applied, thanks.
