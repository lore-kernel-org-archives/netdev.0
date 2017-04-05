From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 4/4] net: dsa: LAN9303: add MDIO managed mode support
Date: Wed, 5 Apr 2017 21:32:19 +0200
Message-ID: <20170405193219.GC25803@lunn.ch>
References: <20170405092024.16048-1-jbe@pengutronix.de>
 <20170405092024.16048-5-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46993 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751069AbdDETcY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 15:32:24 -0400
Content-Disposition: inline
In-Reply-To: <20170405092024.16048-5-jbe@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static const struct of_device_id lan9303_mdio_of_match[] = {
> +	{ .compatible = "smsc,lan9303" },
> +	{ /* sentinel */ },
> +};
> +MODULE_DEVICE_TABLE(of, lan9303_mdio_of_match);

If i'm reading this right, i think you have the same compatible string
for both the i2c and the mdio driver. Does that work? I've no idea.

     Andrew
