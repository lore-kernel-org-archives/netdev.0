From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: bcm_sf2: Register our slave
 MDIO bus
Date: Tue, 7 Jun 2016 02:39:58 +0200
Message-ID: <20160607003958.GQ12165@lunn.ch>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
 <1465254895-11152-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemlof.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60958 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347AbcFGAkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2016 20:40:00 -0400
Content-Disposition: inline
In-Reply-To: <1465254895-11152-6-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 06, 2016 at 04:14:55PM -0700, Florian Fainelli wrote:
> Register a slave MDIO bus which allows us to divert problematic
> read/writes towards conflicting pseudo-PHY address (30). Do no longer
> rely on DSA's slave_mii_bus, but instead provide our own implementation
> which offers more flexibility as to what to do, and when to register it.
> 
> We need to register it by the time we are able to get access to our
> memory mapped registers, which is not until drv->setup() time. In order
> to avoid forward declarations, we need to re-order the function bodies a
> bit.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

	     Andrew
