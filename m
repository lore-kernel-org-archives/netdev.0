From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: bcmgenet: Fix EPHY reset in power up
Date: Fri, 23 Sep 2016 16:06:09 +0200
Message-ID: <20160923140609.GA22965@lunn.ch>
References: <20160923132004.5734-1-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org
To: Jaedon Shin <jaedon.shin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60396 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754692AbcIWOGN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 10:06:13 -0400
Content-Disposition: inline
In-Reply-To: <20160923132004.5734-1-jaedon.shin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 10:20:04PM +0900, Jaedon Shin wrote:
> The bcmgenet_mii_reset() is always not running in power up sequence
> after 'commit 62469c76007e ("net: ethernet: bcmgenet: use phydev from
> struct net_device")'. This'll show extremely high latency and duplicate
> packets while interface down and up repeatedly.
> 
> For now, adds again a private phydev for mii reset when runs power up to
> open interface.

Hi Jaedon

How does this fix the issue? It sounds like you are papering over the
crack, not truly fixing it.

       Andrew
