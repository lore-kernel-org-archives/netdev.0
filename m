From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [for 4.13] net: qcom/emac: fix double free of SGMII
 IRQ during shutdown
Date: Fri, 14 Jul 2017 08:55:51 -0700 (PDT)
Message-ID: <20170714.085551.437530568465293217.davem@davemloft.net>
References: <1499978741-16451-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753568AbdGNPzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 11:55:52 -0400
In-Reply-To: <1499978741-16451-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Thu, 13 Jul 2017 15:45:41 -0500

> If the interface is not up, then don't try to close it during a
> shutdown.  This avoids possible double free of the IRQ, which
> can happen during a shutdown.
> 
> Fixes: 03eb3eb4d4d5 ("net: qcom/emac: add shutdown function")
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied.
