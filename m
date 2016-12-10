From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] net: ethernet: ti: cpsw: re-split res only when
 speed is changed
Date: Sat, 10 Dec 2016 17:30:52 -0500 (EST)
Message-ID: <20161210.173052.703592337860587516.davem@davemloft.net>
References: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
        <1481372630-14914-5-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753241AbcLJWa7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 17:30:59 -0500
In-Reply-To: <1481372630-14914-5-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Sat, 10 Dec 2016 14:23:49 +0200

> Don't re-split res in the following cases:
> - speed of phys is not changed
> - speed of phys is changed and no rate limited channels
> - speed of phys is changed and all channels are rate limited
> - phy is unlinked while dev is open
> - phy is linked back but speed is not changed
> 
> The maximum speed is sum of "linked" phys, thus res are split taken
> in account two interfaces, both for dual emac mode and for
> switch mode.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
