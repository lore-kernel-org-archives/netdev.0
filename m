From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: fix marvell phy status reading
Date: Wed, 31 May 2017 13:53:33 -0400 (EDT)
Message-ID: <20170531.135333.1789972309500724211.davem@davemloft.net>
References: <E1dFixz-00062r-0n@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org
To: rmk+kernel@armlinux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdEaRxl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 13:53:41 -0400
In-Reply-To: <E1dFixz-00062r-0n@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>
Date: Tue, 30 May 2017 16:21:51 +0100

> The Marvell driver incorrectly provides phydev->lp_advertising as the
> logical and of the link partner's advert and our advert.  This is
> incorrect - this field is supposed to store the link parter's unmodified
> advertisment.
> 
> This allows ethtool to report the correct link partner auto-negotiation
> status.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Applied, thank you.
