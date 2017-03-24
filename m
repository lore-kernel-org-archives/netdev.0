From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Export mdiobus_register_board_info()
Date: Thu, 23 Mar 2017 17:14:01 -0700 (PDT)
Message-ID: <20170323.171401.1895711974296614879.davem@davemloft.net>
References: <20170323054030.14613-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdCXAOC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 20:14:02 -0400
In-Reply-To: <20170323054030.14613-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 22 Mar 2017 22:40:30 -0700

> We can build modular code that uses mdiobus_register_board_info() which would
> lead to linking failure since this symbol is not expoerted.
> 
> Fixes: 648ea0134069 ("net: phy: Allow pre-declaration of MDIO devices")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
