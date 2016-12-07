From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] phy: Don't increment MDIO bus refcount unless it's
 a different owner
Date: Wed, 07 Dec 2016 13:29:59 -0500 (EST)
Message-ID: <20161207.132959.1815674717089613175.davem@davemloft.net>
References: <20161207045443.26246-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johan@kernel.org,
        rmk+kernel@arm.linux.org.uk, andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37196 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752121AbcLGSaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:30:01 -0500
In-Reply-To: <20161207045443.26246-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  6 Dec 2016 20:54:43 -0800

> Commit 3e3aaf649416 ("phy: fix mdiobus module safety") fixed the way we
> dealt with MDIO bus module reference count, but sort of introduced a
> regression in that, if an Ethernet driver registers its own MDIO bus
> driver, as is common, we will end up with the Ethernet driver's
> module->refnct set to 1, thus preventing this driver from any removal.
> 
> Fix this by comparing the network device's device driver owner against
> the MDIO bus driver owner, and only if they are different, increment the
> MDIO bus module refcount.
> 
> Fixes: 3e3aaf649416 ("phy: fix mdiobus module safety")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
