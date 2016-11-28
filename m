From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Fix
 mv88e6xxx_g1_irq_free() interrupt count
Date: Mon, 28 Nov 2016 16:04:19 -0500 (EST)
Message-ID: <20161128.160419.2174336587848067302.davem@davemloft.net>
References: <1480285588-13501-1-git-send-email-afaerber@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: uwe@kleine-koenig.org, Michal.Hrusecky@nic.cz,
        tomas.hlavacek@nic.cz, bedrich.kosata@nic.cz, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: afaerber@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755146AbcK1VEV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:04:21 -0500
In-Reply-To: <1480285588-13501-1-git-send-email-afaerber@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Färber <afaerber@suse.de>
Date: Sun, 27 Nov 2016 23:26:28 +0100

> mv88e6xxx_g1_irq_setup() sets up chip->g1_irq.nirqs interrupt mappings,
> so free the same amount. This will be 8 or 9 in practice, less than 16.
> 
> Fixes: dc30c35be720 ("net: dsa: mv88e6xxx: Implement interrupt support.")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Andreas Färber <afaerber@suse.de>

Applied, thanks.
