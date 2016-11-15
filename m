From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/15] net: phy: Centralize auto-negotation restart
Date: Tue, 15 Nov 2016 16:33:56 -0500 (EST)
Message-ID: <20161115.163356.1193714885578021122.davem@davemloft.net>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, tremyfr@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753494AbcKOVeA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 16:34:00 -0500
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 15 Nov 2016 10:06:29 -0800

> This patch series centralizes how ethtool::nway_reset is implemented
> by providing a PHYLIB function which calls into genphy_restart_aneg().
> 
> All drivers below are converted to use this new helper function. Some
> other have specific requirements that make them not quite suitable for
> a straight forward conversion.
> 
> There is another patch series which implements ethtool::nway_reset
> using the helper function introduced that depends on this patch
> series.

Series applied, thanks Florian.
