From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 4/4] net: dsa: LAN9303: add MDIO managed mode support
Date: Fri, 7 Apr 2017 16:19:25 +0200
Message-ID: <20170407141925.GB23415@lunn.ch>
References: <20170407081502.30172-1-jbe@pengutronix.de>
 <20170407081502.30172-5-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170407081502.30172-5-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static const struct of_device_id lan9303_mdio_of_match[] = {
> +	{ .compatible = "smsc,lan9303" },
> +	{ /* sentinel */ },
> +};

We still have the open question of is it a problem to have two
different drivers using the same compatible string. Changing these
strings is hard, once they are in use, so i would prefer to get this
answered before the code is accepted.

	 Andrew
