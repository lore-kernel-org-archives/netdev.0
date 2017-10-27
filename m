From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Simplify dsa_slave_phy_setup()
Date: Fri, 27 Oct 2017 22:11:58 +0900 (KST)
Message-ID: <20171027.221158.217939597639353044.davem@davemloft.net>
References: <20171026003205.13673-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, mnhu@prevas.dk
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752077AbdJ0NMC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 09:12:02 -0400
In-Reply-To: <20171026003205.13673-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 25 Oct 2017 17:32:05 -0700

> Remove the code that tried to identify if a PHY designated by Device
> Tree required diversion through the DSA-created MDIO bus. This was
> created mainly for the bcm_sf2.c driver back when it did not have its
> own MDIO bus driver, which it now has since 461cd1b03e32 ("net: dsa:
> bcm_sf2: Register our slave MDIO bus").
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
