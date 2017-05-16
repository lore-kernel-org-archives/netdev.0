From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net-next: stmmac: add adjust_link function
Date: Tue, 16 May 2017 12:38:09 -0400 (EDT)
Message-ID: <20170516.123809.1468879091622494215.davem@davemloft.net>
References: <20170515114140.1676-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdEPQiL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:38:11 -0400
In-Reply-To: <20170515114140.1676-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Mon, 15 May 2017 13:41:39 +0200

> My dwmac-sun8i serie will add some if (has_sun8i) to
> stmmac_adjust_link()
> Since the current stmmac_adjust_link() alreaady have lots of if (has_gmac/gmac4),
> It is now better to create an adjust_link() function for each dwmac.
> 
> So this patch add an adjust_link() function pointer, and move code out
> of stmmac_adjust_link to it.
> 
> Removing in the process stmmac_mac_flow_ctrl/stmmac_hw_fix_mac_speed
> since there not used anymore.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

This will introduce crashes because you only added the adjust_link
method to one of the two stmmac_ops instances in
drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c

Furthermore, a patch series should always have a header posting
with subject of the format "[PATCH 0/N]: xxx" which describes at
a high level what the patch series does as a whole, how it is doing
it, and why it is doing it that way.

Thank you.
