From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] net: stmmac: fix probe error handling and
 phydev leaks
Date: Fri, 02 Dec 2016 10:43:50 -0500 (EST)
Message-ID: <20161202.104350.1288152600872727205.davem@davemloft.net>
References: <1480516195-27696-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        manabian@gmail.com, carlo@caione.org, khilman@baylibre.com,
        mcoquelin.stm32@gmail.com, maxime.ripard@free-electrons.com,
        wens@csie.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: johan@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbcLBPnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 10:43:53 -0500
In-Reply-To: <1480516195-27696-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hovold <johan@kernel.org>
Date: Wed, 30 Nov 2016 15:29:48 +0100

> This series fixes a number of issues with the stmmac-driver probe error
> handling, which for example left clocks enabled after probe failures.
> 
> The final patch fixes a failure to deregister and free any fixed-link
> PHYs that were registered during probe on probe errors and on driver
> unbind. It also fixes a related of-node leak on late probe errors.
> 
> This series depends on the of_phy_deregister_fixed_link() helper that
> was just merged to net.
> 
> As mentioned earlier, one staging driver also suffers from a similar
> leak and can be fixed up once the above mentioned helper hits mainline.
> 
> Note that these patches have only been compile tested.

Series applied, thanks.
