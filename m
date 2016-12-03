From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ethernet: ti: davinci_cpdma: add missing
 EXPORTs
Date: Sat, 03 Dec 2016 15:27:57 -0500 (EST)
Message-ID: <20161203.152757.961499505116275188.davem@davemloft.net>
References: <20161201202528.12531-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivan.khoronzhuk@linaro.org, mugunthanvnm@ti.com,
        grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36834 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751296AbcLCU2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 15:28:04 -0500
In-Reply-To: <20161201202528.12531-1-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 1 Dec 2016 15:25:28 -0500

> As of commit 8f32b90981dcdb355516fb95953133f8d4e6b11d
> ("net: ethernet: ti: davinci_cpdma: add set rate for a channel") the
> ARM allmodconfig builds would fail modpost with:
> 
> ERROR: "cpdma_chan_set_weight" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
> ERROR: "cpdma_chan_get_rate" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
> ERROR: "cpdma_chan_get_min_rate" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
> ERROR: "cpdma_chan_set_rate" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
> 
> Since these weren't declared as static, it is assumed they were
> meant to be shared outside the file, and that modular build testing
> was simply overlooked.
> 
> Fixes: 8f32b90981dc ("net: ethernet: ti: davinci_cpdma: add set rate for a channel")
> Cc: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: Grygorii Strashko <grygorii.strashko@ti.com>
> Cc: linux-omap@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
