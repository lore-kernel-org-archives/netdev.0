From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/3] net: thunderx: Cleanup PHY probing code.
Date: Fri, 11 Mar 2016 18:31:25 +0100
Message-ID: <20160311173125.GI3153@lunn.ch>
References: <1457714822-5754-1-git-send-email-ddaney.cavm@gmail.com>
 <1457714822-5754-2-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Robert Richter <rric@kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54916 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932124AbcCKRcA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 12:32:00 -0500
Content-Disposition: inline
In-Reply-To: <1457714822-5754-2-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +		phy_np = of_parse_phandle(node, "phy-handle", 0);
> +		/* If there is no phy or defective firmware presents
> +		 * this cortina phy, for which there is no driver
> +		 * support, ignore it.
> +		 */
> +		if (phy_np &&
> +		    !of_device_is_compatible(phy_np, "cortina,cs4223-slice")) {

Hi David

What is a cortina,cs4223-slice, and why does it need to be handled differently?

Thanks
	Andrew
