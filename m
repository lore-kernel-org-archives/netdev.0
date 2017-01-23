From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Avoid deadlock during phy_error()
Date: Mon, 23 Jan 2017 15:37:49 -0500 (EST)
Message-ID: <20170123.153749.133128615698755715.davem@davemloft.net>
References: <20170120233152.16244-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, kyle.roeschley@ni.com,
        rmk+kernel@armlinux.org.uk
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAWUhv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 15:37:51 -0500
In-Reply-To: <20170120233152.16244-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 20 Jan 2017 15:31:52 -0800

> phy_error() is called in the PHY state machine workqueue context, and
> calls phy_trigger_machine() which does a cancel_delayed_work_sync() of
> the workqueue we execute from, causing a deadlock situation.
> 
> Augment phy_trigger_machine() machine with a sync boolean indicating
> whether we should use cancel_*_sync() or just cancel_*_work().
> 
> Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
> Reported-by: Russell King <rmk+kernel@armlinux.org.uk>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
