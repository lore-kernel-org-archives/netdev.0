From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 4/4] net: dsa: LAN9303: add MDIO managed mode support
Date: Fri, 7 Apr 2017 16:54:37 +0200
Message-ID: <20170407145437.GD23415@lunn.ch>
References: <20170407081502.30172-1-jbe@pengutronix.de>
 <20170407081502.30172-5-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49778 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934031AbdDGOyl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 10:54:41 -0400
Content-Disposition: inline
In-Reply-To: <20170407081502.30172-5-jbe@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static const struct of_device_id lan9303_mdio_of_match[] = {
> +	{ .compatible = "smsc,lan9303" },
> +	{ /* sentinel */ },
> +};

I just chatted with Dave about this. Please include mdio and i2c in
the compatible string, so they are different. That will avoid any
possible problems.

	 Andrew
