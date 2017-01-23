From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: ethernet: mvneta: add support for 2.5G DRSGMII mode
Date: Mon, 23 Jan 2017 19:18:36 +0100
Message-ID: <20170123181836.GO10895@lunn.ch>
References: <20170123142206.5390-1-jlu@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        davem@davemloft.net, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Jan Luebbe <jlu@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41900 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750742AbdAWSSk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 13:18:40 -0500
Content-Disposition: inline
In-Reply-To: <20170123142206.5390-1-jlu@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 03:22:06PM +0100, Jan Luebbe wrote:
> The Marvell MVNETA Ethernet controller supports a 2.5 Gbps SGMII mode
> called DRSGMII.
> 
> This patch adds a corresponding phy-mode string 'drsgmii' and parses it
> from DT. The MVNETA then configures the SERDES protocol value
> accordingly.

Hi Jan

So this sets the PHY to 2.5Gbps. What about the MAC? Currently,
mvneta_adjust_link() knows about SPEED_1000 and SPEED_100. Does it now
need to know about SPEED_2500? mvneta_ethtool_set_link_ksettings()?

Thanks
	Andrew
