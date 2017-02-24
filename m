From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Add missing driver check in
 phy_aneg_done()
Date: Fri, 24 Feb 2017 11:20:52 -0500 (EST)
Message-ID: <20170224.112052.36990168643432351.davem@davemloft.net>
References: <20170223222219.6915-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, dan.carpenter@oracle.com,
        rmk+kernel@armlinux.org.uk
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37024 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbdBXQWm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 11:22:42 -0500
In-Reply-To: <20170223222219.6915-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 23 Feb 2017 14:22:19 -0800

> Dan's static checker caught a potential code path in phy_state_machine() where
> we were not checking phydev->drv which is in phy_aneg_done().
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Fixes: 25149ef9d25c ("net: phy: Check phydev->drv")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
