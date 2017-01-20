From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: qcom/emac: configure the external phy to
 allow pause frames"
Date: Thu, 19 Jan 2017 23:15:22 -0500 (EST)
Message-ID: <20170119.231522.474513782085191726.davem@davemloft.net>
References: <1484692279-18289-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alokc@codeaurora.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43412 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbdATEQE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 23:16:04 -0500
In-Reply-To: <1484692279-18289-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Tue, 17 Jan 2017 16:31:19 -0600

> This reverts commit 3e884493448131179a5b7cae1ddca1028ffaecc8.
> 
> With commit 529ed1275263 ("net: phy: phy drivers should not set
> SUPPORTED_[Asym_]Pause"), phylib now handles automatically enabling
> pause frame support in the PHY, and the MAC driver should follow suit.
> 
> Since the EMAC driver driver does this,  we no longer need to force
> pause frames support.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied to net-next.
