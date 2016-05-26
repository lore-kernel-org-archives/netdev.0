From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: stmmac: Fix incorrect memcpy source memory
Date: Thu, 26 May 2016 02:26:25 +0200
Message-ID: <20160526002625.GE21924@lunn.ch>
References: <1464216023-6428-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexandre Torgue <alexandre.torgue@st.com>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51947 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751843AbcEZA0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2016 20:26:30 -0400
Content-Disposition: inline
In-Reply-To: <1464216023-6428-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 12:40:23AM +0200, Marek Vasut wrote:
> The memcpy() currently copies mdio_bus_data into new_bus->irq, which
> makes no sense, since the mdio_bus_data structure contains more than
> just irqs. The code was likely supposed to copy mdio_bus_data->irqs
> into the new_bus->irq instead, so fix this.
> 
> Signed-off-by: Marek Vasut <marex@denx.de>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Alexandre Torgue <alexandre.torgue@st.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

	     Andrew
