From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: bcm_sf2: Unwind errors in correct order
Date: Sat, 30 Jul 2016 23:15:22 -0700 (PDT)
Message-ID: <20160730.231522.2076324866096732670.davem@davemloft.net>
References: <1469820957-21496-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbcGaGPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 02:15:23 -0400
In-Reply-To: <1469820957-21496-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 29 Jul 2016 12:35:57 -0700

> In case we cannot complete bcm_sf2_sw_setup() for any reason, and we
> go to the out_unmap label, but the MDIO bus has not been registered yet,
> we will hit the BUG condition in drivers/net/phy/mdio_bus.c about the
> bus not being registered. Fix this by dedicating a specific lable for
> when we fail after the MDIO bus has been successfully registered.
> 
> Fixes: 461cd1b03e32 ("net: dsa: bcm_sf2: Register our slave MDIO bus")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
