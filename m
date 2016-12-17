From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v2] net: qcom/emac: don't try to claim clocks on ACPI
 systems
Date: Sat, 17 Dec 2016 10:23:00 -0500 (EST)
Message-ID: <20161217.102300.264410138603502889.davem@davemloft.net>
References: <1481672942-20024-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, cov@codeaurora.org,
        alokc@codeaurora.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40388 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757088AbcLQPXC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 10:23:02 -0500
In-Reply-To: <1481672942-20024-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Tue, 13 Dec 2016 17:49:02 -0600

> On ACPI systems, clocks are not available to drivers directly.  They are
> handled exclusively by ACPI and/or firmware, so there is no clock driver.
> Calls to clk_get() always fail, so we should not even attempt to claim
> any clocks on ACPI systems.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
> 
> Notes:
>     v2: move check into functions

Applied, thanks.
