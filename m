From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Fix build module
Date: Tue, 31 Jan 2017 00:32:00 -0500 (EST)
Message-ID: <20170131.003200.1606954363885799024.davem@davemloft.net>
References: <20170131031716.31304-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37158 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdAaFcg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 00:32:36 -0500
In-Reply-To: <20170131031716.31304-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 30 Jan 2017 19:17:16 -0800

> Commit 7318166cacad ("net: dsa: bcm_sf2: Add support for
> ethtool::rxnfc") added a new object to build: bcm_sf2_cfp.o, but in
> doing so, we essentially just built this object and no longer bcm_sf2.o.
> 
> Fix this by creating a module named bcm-sf2.ko which links in bcm_sf2.o
> and bcm_sf2_cfp.o.
> 
> Fixes: 7318166cacad ("net: dsa: bcm_sf2: Add support for ethtool::rxnfc")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
