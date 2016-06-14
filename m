From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] mdio: mux: avoid 'maybe-uninitialized' warning
Date: Tue, 14 Jun 2016 22:45:06 +0200
Message-ID: <20160614204506.GB12832@lunn.ch>
References: <1465898632-2248093-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Pramod Kumar <pramod.kumar@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45980 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205AbcFNUpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 16:45:11 -0400
Content-Disposition: inline
In-Reply-To: <1465898632-2248093-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 12:03:17PM +0200, Arnd Bergmann wrote:
> The latest changes to the MDIO code introduced a false-positive
> warning with gcc-6 (possibly others):
> 
> drivers/net/phy/mdio-mux.c: In function 'mdio_mux_init':
> drivers/net/phy/mdio-mux.c:188:3: error: 'parent_bus_node' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> It's easy to avoid the warning by making sure the parent_bus_node
> is initialized in both cases at the start of the function, since
> the later 'of_node_put()' call is also valid for a NULL pointer
> argument.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: f20e6657a875 ("mdio: mux: Enhanced MDIO mux framework for integrated multiplexers")

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks Arnd

    Andrew
