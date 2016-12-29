From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: stmmac: Fix error path after register_netdev
 move
Date: Thu, 29 Dec 2016 12:08:42 -0500 (EST)
Message-ID: <20161229.120842.467810433862780290.davem@davemloft.net>
References: <20161228234441.5026-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pavel@ucw.cz, Joao.Pinto@synopsys.com,
        seraphin.bonnaffe@st.com, alexandre.torgue@gmail.com,
        manabian@gmail.com, niklas.cassel@axis.com, johan@kernel.org,
        boon.leong.ong@intel.com, weifeng.voon@intel.com,
        lars.persson@axis.com, linux-kernel@vger.kernel.org,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54672 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753174AbcL2RIp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:08:45 -0500
In-Reply-To: <20161228234441.5026-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 28 Dec 2016 15:44:41 -0800

> Commit 5701659004d6 ("net: stmmac: Fix race between stmmac_drv_probe and
> stmmac_open") re-ordered how the MDIO bus registration and the network
> device are registered, but missed to unwind the MDIO bus registration in
> case we fail to register the network device.
> 
> Fixes: 5701659004d6 ("net: stmmac: Fix race between stmmac_drv_probe and stmmac_open")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
