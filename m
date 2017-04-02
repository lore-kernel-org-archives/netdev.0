From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 05/13] ftgmac100: Cleanup speed/duplex tracking and fix
 duplex config
Date: Sun, 2 Apr 2017 20:28:48 +0200
Message-ID: <20170402182848.GA5189@lunn.ch>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
 <20170402033523.9482-6-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43164 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751557AbdDBS2u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 14:28:50 -0400
Content-Disposition: inline
In-Reply-To: <20170402033523.9482-6-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	if (new_speed) {
> +		netdev_info(netdev, "Link up at %d Mbit/s %s duplex\n",
> +			    new_speed,
> +			    phydev->duplex == DUPLEX_FULL ? "full" : "half");
> +	} else if (priv->cur_speed) {
> +		/* No link, just return. Leave the HW alone so it can
> +		 * continue draining the tx ring.
> +		 */
> +		netdev_info(netdev, "Link down\n");
>  		return;

Hi Ben

Please consider using phy_print_status().

       Andrew
